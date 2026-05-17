import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_queue_service.dart';
import 'package:flutter/foundation.dart';

class JournalService {
  final AppDatabase _db;
  final SupabaseClient _supabase = Supabase.instance.client;
  final SyncQueueService _syncQueue;

  JournalService(this._db, this._syncQueue);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // ── Load Journal Entries (Supabase first, local fallback) ──────────────

  Future<List<JournalEntry>> getAllJournalEntries() async {
    final userId = _currentUserId;
    if (userId != null) {
      try {
        final data = await _supabase
            .from('journal_entries')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        final entries = data.map((row) => _entryFromSupabase(row)).toList();

        // Sync to local database for offline support with conflict resolution
        final pendingIds = _syncQueue.queue
            .where((op) => op.type == SyncOperationType.saveJournalEntry)
            .map((op) => op.data['id'] as String)
            .toSet();

        for (final entry in entries) {
          if (!pendingIds.contains(entry.id)) {
            await _db.insertJournalEntry(entry);
          } else {
            debugPrint(
              '🛡️ JournalService: Conflict prevented. Preserved local dirty journal entry ID: ${entry.id}',
            );
          }
        }
      } catch (e) {
        debugPrint(
          'JournalService: Error fetching from Supabase, using local: $e',
        );
      }
    }

    // Always query and return from local SQLite as the single source of truth
    return _db.getAllJournalEntries();
  }

  Future<JournalEntry?> getEntryForToday() async {
    final userId = _currentUserId;
    if (userId != null) {
      try {
        final today = DateTime.now();
        final start = DateTime(today.year, today.month, today.day);
        final end = start.add(const Duration(days: 1));

        final data = await _supabase
            .from('journal_entries')
            .select()
            .eq('user_id', userId)
            .gte('created_at', start.toIso8601String())
            .lt('created_at', end.toIso8601String())
            .maybeSingle();

        if (data != null) {
          final entry = _entryFromSupabase(data);
          await _db.insertJournalEntry(entry);
        }
      } catch (e) {
        debugPrint(
          'JournalService: Error fetching today\'s entry from Supabase: $e',
        );
      }
    }

    // Always query and return from local SQLite as the single source of truth
    return _db.getEntryForToday();
  }

  Future<List<JournalEntry>> getEntriesForMonth(int year, int month) async {
    final userId = _currentUserId;
    if (userId != null) {
      try {
        final start = DateTime(year, month);
        final end = DateTime(year, month + 1);

        final data = await _supabase
            .from('journal_entries')
            .select()
            .eq('user_id', userId)
            .gte('created_at', start.toIso8601String())
            .lt('created_at', end.toIso8601String())
            .order('created_at', ascending: false);

        return data.map((row) => _entryFromSupabase(row)).toList();
      } catch (e) {
        debugPrint('JournalService: Error fetching month from Supabase: $e');
      }
    }

    return _db.getEntriesForMonth(year, month);
  }

  Future<List<JournalEntry>> getRecentEntries({int limit = 30}) async {
    final userId = _currentUserId;
    if (userId != null) {
      try {
        final data = await _supabase
            .from('journal_entries')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .limit(limit);

        return data.map((row) => _entryFromSupabase(row)).toList();
      } catch (e) {
        debugPrint(
          'JournalService: Error fetching recent entries from Supabase: $e',
        );
      }
    }

    return _db.getRecentEntries(limit: limit);
  }

  // ── Save Journal Entry (Local first, then Supabase via SyncQueue) ────────────────────

  Future<void> saveJournalEntry(JournalEntry entry) async {
    // Save locally first (instant)
    await _db.insertJournalEntry(entry);

    // Sync to Supabase in background via SyncQueue
    final userId = _currentUserId;
    if (userId != null) {
      _syncQueue.addToQueue(
        SyncOperation(
          id: 'create_journal_entry_${entry.id}',
          type: SyncOperationType.saveJournalEntry,
          data: _entryToSupabaseMap(entry, userId),
          createdAt: DateTime.now(),
        ),
      );
      debugPrint('JournalService: 📦 Journal entry added to Sync Queue');
    }
  }

  // ── Initial Data Fetch from Supabase ────────────────────────────────────

  /// Fetches all journal entries from Supabase and populates local database.
  /// Call this on app startup after user login.
  Future<void> fetchFromSupabase() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final data = await _supabase
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      debugPrint(
        'JournalService: ✅ Fetched ${data.length} journal entries from Supabase',
      );

      final pendingIds = _syncQueue.queue
          .where((op) => op.type == SyncOperationType.saveJournalEntry)
          .map((op) => op.data['id'] as String)
          .toSet();

      for (final row in data) {
        final entry = _entryFromSupabase(row);
        if (!pendingIds.contains(entry.id)) {
          await _db.insertJournalEntry(entry);
        } else {
          debugPrint(
            '🛡️ JournalService: Conflict prevented in fetch. Preserved local dirty journal entry ID: ${entry.id}',
          );
        }
      }
    } catch (e) {
      debugPrint('JournalService: ⚠️ Failed to fetch from Supabase: $e');
    }
  }

  // ── Helpers: Supabase ↔ Local ─────────────────────────────────────────

  Map<String, dynamic> _entryToSupabaseMap(JournalEntry entry, String userId) {
    return {
      'id': entry.id,
      'user_id': userId,
      'content': entry.content,
      'mood': entry.mood,
      'mood_score': entry.moodScore,
      'created_at': entry.createdAt.toIso8601String(),
    };
  }

  JournalEntry _entryFromSupabase(Map<String, dynamic> row) {
    return JournalEntry(
      id: row['id'] as String,
      content: row['content'] as String,
      mood: row['mood'] as String,
      moodScore: row['mood_score'] as int? ?? 3,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
