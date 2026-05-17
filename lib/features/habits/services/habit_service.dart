import '../../../core/database/app_database.dart';

class HabitService {
  final AppDatabase _db;

  HabitService(this._db);

  Future<List<Habit>> getAllHabits() => _db.getAllHabits();

  Future<void> saveHabit(Habit habit) async {
    await _db.insertHabit(habit);
  }

  Future<void> updateHabit(Habit habit) async {
    await _db.updateHabit(habit);
  }

  Future<void> logCompletion(HabitLog log) async {
    await _db.insertLog(log);
  }

  /// All logs for a habit (for streak computation).
  Future<List<HabitLog>> getLogsForHabit(String habitId) =>
      _db.getLogsForHabit(habitId);

  /// Logs for a habit since [since] (lighter query for recent history).
  Future<List<HabitLog>> getLogsForHabitSince(
          String habitId, DateTime since) =>
      _db.getLogsForHabitSince(habitId, since);

  /// All logs for a specific date (used by garden growth engine).
  Future<List<HabitLog>> getLogsForDate(DateTime date) =>
      _db.getLogsForDate(date);

  Future<void> archiveHabit(String habitId) => _db.archiveHabit(habitId);
}
