import '../../../core/database/app_database.dart';

class TaskService {
  final AppDatabase _db;

  TaskService(this._db);

  Future<List<Task>> getActiveTasks() => _db.getActiveTasks();

  Future<List<Task>> getCompletedTasks() => _db.getCompletedTasks();

  Future<void> saveTask(Task task) async {
    await _db.insertTask(task);
  }

  Future<void> updateTask(Task task) async {
    await _db.updateTask(task);
  }

  Future<void> deleteTask(String id) async {
    await _db.deleteTask(id);
  }
}
