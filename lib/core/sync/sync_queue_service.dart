import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a failed sync operation that needs to be retried
enum SyncOperationType {
  createHabit,
  updateHabit,
  deleteHabit,
  logHabitCompletion,
  createTask,
  updateTask,
  deleteTask,
  completeTask,
  saveJournalEntry,
}

class SyncOperation {
  final String id;
  final SyncOperationType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  int retryCount;

  SyncOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'retry_count': retryCount,
    };
  }

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      type: SyncOperationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => SyncOperationType.createHabit,
      ),
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
      retryCount: json['retry_count'] as int? ?? 0,
    );
  }
}

/// Service to manage offline sync queue and retry failed operations
class SyncQueueService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final List<SyncOperation> _queue = [];
  Timer? _retryTimer;
  StreamSubscription? _connectivitySubscription;
  bool _isProcessing = false;
  bool _isOffline = false;
  DateTime? _lastSyncTime;

  bool get isOffline => _isOffline;
  DateTime? get lastSyncTime => _lastSyncTime;

  // ── Queue Management ───────────────────────────────

  void addToQueue(SyncOperation operation) {
    _queue.add(operation);
    debugPrint('📦 SyncQueue: Added ${operation.type.name} to queue (${_queue.length} total)');
    _saveQueueToStorage();
    notifyListeners();
    _processQueue();
  }

  void removeFromQueue(String operationId) {
    _queue.removeWhere((op) => op.id == operationId);
    _saveQueueToStorage();
    notifyListeners();
  }

  // ── Network Monitoring ──────────────────────────────

  void startNetworkMonitoring() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final hasConnection = results.any((r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn);
      if (hasConnection) {
        _isOffline = false;
        debugPrint('🌐 SyncQueue: Network connected, processing queue...');
        _processQueue();
      } else {
        _isOffline = true;
        debugPrint('📵 SyncQueue: Network disconnected');
        notifyListeners();
      }
    });
  }

  void stopNetworkMonitoring() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
  }

  // ── Queue Processing ────────────────────────────────

  Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;
    notifyListeners();
    debugPrint('🔄 SyncQueue: Processing ${_queue.length} pending operations...');

    final failedOperations = <SyncOperation>[];

    for (final operation in List.from(_queue)) {
      try {
        final success = await _executeOperation(operation);
        if (success) {
          removeFromQueue(operation.id);
          debugPrint('✅ SyncQueue: Successfully processed ${operation.type.toString().split('.').last}');
        } else {
          operation.retryCount++;
          if (operation.retryCount < 5) {
            failedOperations.add(operation);
          } else {
            debugPrint('❌ SyncQueue: Max retries exceeded for ${operation.type.toString().split('.').last}');
            removeFromQueue(operation.id);
          }
        }
      } catch (e) {
        debugPrint('⚠️ SyncQueue: Error processing ${operation.type.toString().split('.').last}: $e');

        // If it's a row-level security error (RLS policy violation), Forbidden, or 42501 permission issue,
        // it's a permanent security/permission failure. We should permanently discard ONLY this operation 
        // to avoid infinite retries/spam and prevent clearing other completely valid offline sync operations.
        final isPermanentError = e.toString().contains('row-level security policy') ||
            e.toString().contains('42501') ||
            e.toString().contains('Forbidden');

        if (isPermanentError) {
          debugPrint('🚫 RLS violation or Forbidden detected for operation ${operation.id}, permanently discarding to prevent clogging the sync queue.');
          removeFromQueue(operation.id);
        } else {
          operation.retryCount++;
          if (operation.retryCount < 5) {
            failedOperations.add(operation);
          } else {
            debugPrint('❌ SyncQueue: Max retries exceeded for ${operation.type.toString().split('.').last}');
            removeFromQueue(operation.id);
          }
        }
      }
    }

    // Update queue with failed operations
    _queue.clear();
    _queue.addAll(failedOperations);
    _saveQueueToStorage();

    _isProcessing = false;
    notifyListeners();

    // Schedule retry if there are still pending operations
    if (_queue.isNotEmpty) {
      _scheduleRetry();
    } else {
      _lastSyncTime = DateTime.now();
      debugPrint('🎉 SyncQueue: All operations processed successfully!');
    }
  }

  Future<bool> _executeOperation(SyncOperation operation) async {
    try {
      switch (operation.type) {
        case SyncOperationType.createHabit:
        case SyncOperationType.updateHabit:
          // Use upsert to handle both insert and update idempotently.
          // Safely convert any unsigned color values on the fly to signed 32-bit
          // integers to guarantee Postgres compatibility for legacy or cached data.
          final Map<String, dynamic> sanitizedData = Map<String, dynamic>.from(operation.data);
          if (sanitizedData.containsKey('icon_bg')) {
            final iconBg = sanitizedData['icon_bg'];
            if (iconBg is int) {
              sanitizedData['icon_bg'] = iconBg.toSigned(32);
            }
          }
          await _supabase.from('habits').upsert(sanitizedData);
          return true;

        case SyncOperationType.deleteHabit:
          await _supabase.from('habits').delete().eq('id', operation.data['id']);
          return true;

        case SyncOperationType.logHabitCompletion:
          await _supabase.from('habit_logs').upsert(operation.data);
          return true;

        case SyncOperationType.createTask:
        case SyncOperationType.updateTask:
        case SyncOperationType.completeTask:
          await _supabase.from('tasks').upsert(operation.data);
          return true;

        case SyncOperationType.deleteTask:
          await _supabase.from('tasks').delete().eq('id', operation.data['id']);
          return true;

        case SyncOperationType.saveJournalEntry:
          await _supabase.from('journal_entries').upsert(operation.data);
          return true;
      }
    } catch (e) {
      debugPrint('SyncQueue._executeOperation error: $e');
      debugPrint('SyncQueue._executeOperation failed data payload: ${operation.data}');
      rethrow;
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: 30), () {
      debugPrint('🔄 SyncQueue: Retrying failed operations...');
      _processQueue();
    });
  }

  // ── Storage ─────────────────────────────────────────

  Future<void> _saveQueueToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _queue.map((op) => op.toJson()).toList();
      await prefs.setString('sync_queue', jsonEncode(jsonList));
      debugPrint('📦 SyncQueue: Persisted ${_queue.length} operations to SharedPreferences');
    } catch (e) {
      debugPrint('❌ SyncQueue: Failed to save queue to storage: $e');
    }
  }

  Future<void> loadQueueFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('sync_queue');
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
        _queue.clear();
        _queue.addAll(jsonList.map((json) => SyncOperation.fromJson(json as Map<String, dynamic>)));
        debugPrint('📦 SyncQueue: Loaded ${_queue.length} operations from SharedPreferences');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ SyncQueue: Failed to load queue from storage: $e');
    }
  }

  // ── Manual Sync ─────────────────────────────────────

  Future<void> forceSync() async {
    debugPrint('⚡ SyncQueue: Force sync triggered');
    await _processQueue();
  }

  // ── Queue Status ────────────────────────────────────

  int get pendingCount => _queue.length;
  bool get isProcessing => _isProcessing;
  List<SyncOperation> get queue => List.unmodifiable(_queue);

  /// Clear all pending sync operations
  void clearQueue() {
    _queue.clear();
    _saveQueueToStorage();
    notifyListeners();
    debugPrint('🗑️ SyncQueue: Cleared all pending operations');
  }
}
