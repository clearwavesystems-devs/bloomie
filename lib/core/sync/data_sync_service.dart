import 'package:flutter/foundation.dart';
import '../../features/habits/services/habit_service.dart';
import '../../features/task/services/task_service.dart';
import '../../features/journal/services/journal_service.dart';

/// Service to sync all user data from Supabase to local database.
/// Call this on app startup after user login to restore data.
class DataSyncService {
  final HabitService _habitService;
  final TaskService _taskService;
  final JournalService _journalService;

  DataSyncService({
    required HabitService habitService,
    required TaskService taskService,
    required JournalService journalService,
  }) : _habitService = habitService,
       _taskService = taskService,
       _journalService = journalService;

  /// Fetches all user data from Supabase and populates local database.
  /// This should be called after user login or app startup.
  ///
  /// Returns true if sync was successful, false otherwise.
  Future<bool> syncFromSupabase() async {
    try {
      debugPrint('🔄 DataSyncService: Starting sync from Supabase...');

      // Fetch habits
      final habits = await _habitService.getAllHabits();
      debugPrint('✅ DataSyncService: Synced ${habits.length} habits');

      // Fetch tasks
      final activeTasks = await _taskService.getActiveTasks();
      final completedTasks = await _taskService.getCompletedTasks();
      debugPrint(
        '✅ DataSyncService: Synced ${activeTasks.length + completedTasks.length} tasks',
      );

      // Fetch journal entries
      final entries = await _journalService.getAllJournalEntries();
      debugPrint('✅ DataSyncService: Synced ${entries.length} journal entries');

      debugPrint('🎉 DataSyncService: Sync complete!');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSyncService: Sync failed: $e');
      debugPrint('StackTrace: $stackTrace');
      return false;
    }
  }

  /// Syncs data from Supabase without blocking the UI.
  /// This is useful for background sync on app startup.
  Future<void> syncInBackground() async {
    // Run in background to avoid blocking UI
    await Future.delayed(Duration.zero);
    await syncFromSupabase();
  }
}
