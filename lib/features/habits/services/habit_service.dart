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

  Future<List<HabitLog>> getLogsForHabit(String habitId) => _db.getLogsForHabit(habitId);

  Future<void> archiveHabit(String habitId) => _db.archiveHabit(habitId);
}
