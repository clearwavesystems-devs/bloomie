import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_queue_service.dart';
import 'package:flutter/foundation.dart';

class TaskService {
  final AppDatabase _db;
  final SupabaseClient _supabase = Supabase.instance.client;
  final SyncQueueService _syncQueue;

  TaskService(this._db, this._syncQueue);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // ── Load Tasks (Supabase first, local fallback) ───────────────────────

  Future<List<Task>> getActiveTasks() async {
    final userId = _currentUserId;
    if (userId != null) {
      try {
        final data = await _supabase
            .from('tasks')
            .select()
            .eq('user_id', userId)
            .eq('completed', false)
            .order('created_at', ascending: true);

        final tasks = data.map((row) => _taskFromSupabase(row)).toList();

        // Sync to local database for offline support with conflict resolution
        final pendingIds = _syncQueue.queue
            .where(
              (op) =>
                  op.type == SyncOperationType.createTask ||
                  op.type == SyncOperationType.updateTask ||
                  op.type == SyncOperationType.completeTask ||
                  op.type == SyncOperationType.deleteTask,
            )
            .map((op) => op.data['id'] as String)
            .toSet();

        for (final task in tasks) {
          if (!pendingIds.contains(task.id)) {
            await _db.insertTask(task);
          } else {
            debugPrint(
              '🛡️ TaskService: Conflict prevented. Preserved local dirty task ID: ${task.id}',
            );
          }
        }
      } catch (e) {
        debugPrint(
          'TaskService: Error fetching from Supabase, using local: $e',
        );
      }
    }

    // Always query and return from local SQLite as the single source of truth
    final localUserId = _currentUserId ?? 'me';
    return _db.getActiveTasks(localUserId);
  }

  Future<List<Task>> getCompletedTasks() async {
    final userId = _currentUserId;
    if (userId != null) {
      try {
        final data = await _supabase
            .from('tasks')
            .select()
            .eq('user_id', userId)
            .eq('completed', true)
            .order('completed_at', ascending: false);

        final tasks = data.map((row) => _taskFromSupabase(row)).toList();
        for (final task in tasks) {
          await _db.insertTask(task);
        }
      } catch (e) {
        debugPrint('TaskService: Error fetching completed from Supabase: $e');
      }
    }

    // Always query and return from local SQLite as the single source of truth
    final localUserId = _currentUserId ?? 'me';
    return _db.getCompletedTasks(localUserId);
  }

  // ── Save Task (Local first, then Supabase via SyncQueue) ───────────────────

  Future<void> saveTask(Task task) async {
    // Always save locally for offline support (instant)
    // Use actual user ID if available, otherwise keep 'me'
    final userId = _currentUserId ?? task.userId;
    final taskWithUser = task.copyWith(userId: userId);
    await _db.insertTask(taskWithUser);

    // Sync to Supabase in background via SyncQueue
    if (_currentUserId != null) {
      _syncQueue.addToQueue(
        SyncOperation(
          id: 'create_task_${task.id}',
          type: SyncOperationType.createTask,
          data: _taskToSupabaseMap(taskWithUser, _currentUserId!),
          createdAt: DateTime.now(),
        ),
      );
      debugPrint(
        'TaskService: 📦 Task save added to Sync Queue: ${task.title}',
      );
    }
  }

  // ── Update Task (Local first, then Supabase via SyncQueue) ─────────────────

  Future<void> updateTask(Task task) async {
    // Always save locally (instant)
    final userId = _currentUserId ?? task.userId;
    final taskWithUser = task.copyWith(userId: userId);
    await _db.updateTask(taskWithUser);

    // Sync to Supabase in background via SyncQueue
    if (_currentUserId != null) {
      _syncQueue.addToQueue(
        SyncOperation(
          id: 'update_task_${task.id}',
          type: SyncOperationType.updateTask,
          data: _taskToSupabaseMap(taskWithUser, _currentUserId!),
          createdAt: DateTime.now(),
        ),
      );
      debugPrint(
        'TaskService: 📦 Task update added to Sync Queue: ${task.title}',
      );
    }
  }

  // ── Delete Task (Local first, then Supabase via SyncQueue) ─────────────────

  Future<void> deleteTask(String id) async {
    // Delete locally first (instant)
    await _db.deleteTask(id);

    // Sync to Supabase in background via SyncQueue
    final userId = _currentUserId;
    if (userId != null) {
      _syncQueue.addToQueue(
        SyncOperation(
          id: 'delete_task_$id',
          type: SyncOperationType.deleteTask,
          data: {'id': id, 'user_id': userId},
          createdAt: DateTime.now(),
        ),
      );
      debugPrint('TaskService: 📦 Task deletion added to Sync Queue');
    }
  }

  // ── Initial Data Fetch from Supabase ────────────────────────────────────

  /// Fetches all tasks from Supabase and populates local database.
  /// Call this on app startup after user login.
  Future<void> fetchFromSupabase() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final data = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      debugPrint('TaskService: ✅ Fetched ${data.length} tasks from Supabase');

      final pendingIds = _syncQueue.queue
          .where(
            (op) =>
                op.type == SyncOperationType.createTask ||
                op.type == SyncOperationType.updateTask ||
                op.type == SyncOperationType.completeTask ||
                op.type == SyncOperationType.deleteTask,
          )
          .map((op) => op.data['id'] as String)
          .toSet();

      for (final row in data) {
        final task = _taskFromSupabase(row);
        if (!pendingIds.contains(task.id)) {
          await _db.insertTask(task);
        } else {
          debugPrint(
            '🛡️ TaskService: Conflict prevented in fetch. Preserved local dirty task ID: ${task.id}',
          );
        }
      }
    } catch (e) {
      debugPrint('TaskService: ⚠️ Failed to fetch from Supabase: $e');
    }
  }

  // ── Helpers: Supabase ↔ Local ─────────────────────────────────────────

  Map<String, dynamic> _taskToSupabaseMap(Task task, String userId) {
    return {
      'id': task.id,
      'user_id': userId,
      'title': task.title,
      'description': task.description,
      'xp_reward': task.xpReward,
      'bloom_reward': task.bloomReward,
      'completed': task.completed,
      'due_at': task.dueAt?.toIso8601String(),
      'completed_at': task.completedAt?.toIso8601String(),
      'created_at': task.createdAt.toIso8601String(),
      'estimated_minutes': task.estimatedMinutes,
    };
  }

  Task _taskFromSupabase(Map<String, dynamic> row) {
    return Task(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      title: row['title'] as String,
      description: row['description'] as String?,
      xpReward: row['xp_reward'] as int? ?? 20,
      bloomReward: row['bloom_reward'] as int? ?? 5,
      completed: row['completed'] as bool? ?? false,
      dueAt: row['due_at'] != null
          ? DateTime.parse(row['due_at'] as String)
          : null,
      completedAt: row['completed_at'] != null
          ? DateTime.parse(row['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(row['created_at'] as String),
      estimatedMinutes: row['estimated_minutes'] as int?,
    );
  }
}
