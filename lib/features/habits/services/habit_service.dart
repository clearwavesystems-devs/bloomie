import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_queue_service.dart';

class HabitService {
  final AppDatabase _db;
  final SupabaseClient _supabase = Supabase.instance.client;
  final SyncQueueService _syncQueue;

  HabitService(this._db, this._syncQueue);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // ── Load Habits (Supabase first, local fallback) ─────────────────────

  Future<List<Habit>> getAllHabits() async {
    final userId = _currentUserId;
    if (userId != null) {
      try {
        // Fetch from Supabase
        final data = await _supabase
            .from('habits')
            .select()
            .eq('user_id', userId)
            .eq('is_archived', false)
            .order('created_at', ascending: false);

        final habits = data.map((row) => _habitFromSupabase(row)).toList();

        // Sync to local database for offline support with conflict resolution
        final pendingIds = _syncQueue.queue
            .where(
              (op) =>
                  op.type == SyncOperationType.createHabit ||
                  op.type == SyncOperationType.updateHabit,
            )
            .map((op) => op.data['id'] as String)
            .toSet();

        for (final habit in habits) {
          if (!pendingIds.contains(habit.id)) {
            await _db.insertHabit(habit);
          } else {
            debugPrint(
              '🛡️ HabitService: Conflict prevented. Preserved local dirty habit ID: ${habit.id}',
            );
          }
        }
      } catch (e) {
        debugPrint(
          'HabitService: Error fetching from Supabase, using local: $e',
        );
      }
    }

    // Always query and return from local SQLite as the single source of truth
    final localUserId = userId ?? 'me'; // Default to 'me' if not logged in
    debugPrint('Getting habits for user: $localUserId');
    final habits = await _db.getAllHabits(localUserId);
    debugPrint('Found ${habits.length} habits for user $localUserId');
    return habits;
  }

  // ── Save Habit (Supabase + Local via SyncQueue) ─────────────────────────

  Future<void> saveHabit(Habit habit) async {
    // Always save locally for offline support (instant)
    // Use actual user ID if available, otherwise keep 'me'
    final userId = _currentUserId ?? habit.userId;
    final habitWithUser = habit.copyWith(userId: userId);
    await _db.insertHabit(habitWithUser);

    // Sync to Supabase if user is logged in
    if (_currentUserId != null) {
      final habitMap = _habitToSupabaseMap(habitWithUser, _currentUserId!);
      _syncQueue.addToQueue(
        SyncOperation(
          id: 'create_habit_${habit.id}',
          type: SyncOperationType.createHabit,
          data: habitMap,
          createdAt: DateTime.now(),
        ),
      );
      debugPrint(
        'HabitService: 📦 Habit save added to Sync Queue: ${habit.name}',
      );
    }
  }

  // ── Update Habit (Supabase + Local via SyncQueue) ───────────────────────

  Future<void> updateHabit(Habit habit) async {
    // Always save locally (instant)
    await _db.updateHabit(habit);

    final userId = _currentUserId;
    if (userId != null) {
      final habitMap = _habitToSupabaseMap(habit, userId);
      _syncQueue.addToQueue(
        SyncOperation(
          id: 'update_habit_${habit.id}',
          type: SyncOperationType.updateHabit,
          data: habitMap,
          createdAt: DateTime.now(),
        ),
      );
      debugPrint(
        'HabitService: 📦 Habit update added to Sync Queue: ${habit.name}',
      );
    }
  }

  // ── Log Completion (Supabase + Local via SyncQueue) ─────────────────────

  Future<void> logCompletion(HabitLog log) async {
    // Always save locally (instant)
    await _db.insertLog(log);

    final userId = _currentUserId;
    if (userId != null) {
      _syncQueue.addToQueue(
        SyncOperation(
          id: 'log_completion_${log.id}',
          type: SyncOperationType.logHabitCompletion,
          data: {
            'id': log.id,
            'habit_id': log.habitId,
            'user_id': userId,
            'completed_at': log.completedAt.toIso8601String(),
            'count': log.count,
            'note': log.note,
          },
          createdAt: DateTime.now(),
        ),
      );
      debugPrint('HabitService: 📦 Completion log added to Sync Queue');
    }
  }

  // ── Archive Habit (Supabase + Local via SyncQueue) ──────────────────────

  Future<void> archiveHabit(String habitId) async {
    // Always archive locally (instant)
    await _db.archiveHabit(habitId);

    final userId = _currentUserId;
    if (userId != null) {
      _syncQueue.addToQueue(
        SyncOperation(
          id: 'archive_habit_$habitId',
          type: SyncOperationType.updateHabit,
          data: {'id': habitId, 'user_id': userId, 'is_archived': true},
          createdAt: DateTime.now(),
        ),
      );
      debugPrint('HabitService: 📦 Habit archival added to Sync Queue');
    }
  }

  // ── Logs Queries (Local only for speed) ───────────────────────────────

  Future<List<HabitLog>> getLogsForHabit(String habitId) =>
      _db.getLogsForHabit(habitId);

  Future<List<HabitLog>> getLogsForHabitSince(String habitId, DateTime since) =>
      _db.getLogsForHabitSince(habitId, since);

  Future<List<HabitLog>> getLogsForDate(DateTime date) =>
      _db.getLogsForDate(date);

  // ── Helpers: Supabase ↔ Local ─────────────────────────────────────────

  Map<String, dynamic> _habitToSupabaseMap(Habit habit, String userId) {
    return {
      'id': habit.id,
      'user_id': userId,
      'name': habit.name,
      'emoji': habit.emoji,
      'category': habit.category,
      'frequency': habit.frequency,
      'custom_days': habit.customDays,
      'target_count': habit.targetCount,
      'current_count': habit.currentCount,
      'streak_count': habit.streakCount,
      'longest_streak': habit.longestStreak,
      'xp_reward': habit.xpReward,
      'icon_bg': habit.iconBg.toSigned(32),
      'is_shared_with_partner': habit.isSharedWithPartner,
      'is_archived': habit.isArchived,
      'created_at': habit.createdAt.toIso8601String(),
      'last_completed_at': habit.lastCompletedAt?.toIso8601String(),
      'reminder_time': habit.reminderTime?.toIso8601String(),
    };
  }

  Habit _habitFromSupabase(Map<String, dynamic> row) {
    return Habit(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      name: row['name'] as String,
      emoji: row['emoji'] as String,
      category: row['category'] as int,
      frequency: row['frequency'] as int,
      customDays: row['custom_days'] as String? ?? '[]',
      targetCount: row['target_count'] as int? ?? 1,
      currentCount: row['current_count'] as int? ?? 0,
      streakCount: row['streak_count'] as int? ?? 0,
      longestStreak: row['longest_streak'] as int? ?? 0,
      xpReward: row['xp_reward'] as int? ?? 50,
      iconBg: (row['icon_bg'] as int? ?? 0xFFFFFFFF) & 0xFFFFFFFF,
      isSharedWithPartner: row['is_shared_with_partner'] as bool? ?? false,
      isArchived: row['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(row['created_at'] as String),
      lastCompletedAt: row['last_completed_at'] != null
          ? DateTime.parse(row['last_completed_at'] as String)
          : null,
      reminderTime: row['reminder_time'] != null
          ? DateTime.parse(row['reminder_time'] as String)
          : null,
    );
  }
}
