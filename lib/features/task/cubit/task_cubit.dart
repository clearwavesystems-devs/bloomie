import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';
import '../services/task_service.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskService _taskService;
  final ProfileCubit _profileCubit;
  Timer? _timer;

  TaskCubit(this._taskService, this._profileCubit) : super(TaskInitial());

  // ── Load ───────────────────────────────────

  Future<void> loadTasks() async {
    emit(TaskLoading());
    try {
      final active = await _taskService.getActiveTasks();
      final completed = await _taskService.getCompletedTasks();
      emit(TaskLoaded(
        activeTasks: active,
        completedTasks: completed,
      ));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // ── Add ────────────────────────────────────

  Future<void> addTask({
    required String title,
    String? description,
    int xpReward = 20,
    int bloomReward = 5,
    DateTime? dueAt,
    int? estimatedMinutes,
  }) async {
    try {
      // Get user ID from profile
      final profileState = _profileCubit.state;
      if (profileState is! ProfileLoaded) {
        emit(TaskError('User profile not loaded'));
        return;
      }

      final task = Task(
        id: const Uuid().v4(),
        userId: profileState.user.id,
        title: title,
        description: description,
        xpReward: xpReward,
        bloomReward: bloomReward,
        completed: false,
        dueAt: dueAt,
        createdAt: DateTime.now(),
        estimatedMinutes: estimatedMinutes,
      );

      await _taskService.saveTask(task);
      
      // Reload keeping current timer if active
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        final active = await _taskService.getActiveTasks();
        final completed = await _taskService.getCompletedTasks();
        emit(current.copyWith(
          activeTasks: active,
          completedTasks: completed,
        ));
      } else {
        await loadTasks();
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // ── Complete ───────────────────────────────

  Future<void> completeTask(String id) async {
    if (state is! TaskLoaded) return;
    final current = state as TaskLoaded;

    try {
      final task = current.activeTasks.firstWhere((t) => t.id == id);
      
      // Stop timer if it was running for this task
      final wasTimerRunning = current.activeTimerTaskId == id;
      if (wasTimerRunning) {
        stopTimer();
      }

      final now = DateTime.now();
      final updated = task.copyWith(
        completed: true,
        completedAt: Value(now),
      );

      await _taskService.updateTask(updated);

      // Award rewards through ProfileCubit
      await _profileCubit.addXP(task.xpReward, isFocusTask: wasTimerRunning || task.estimatedMinutes != null);
      await _profileCubit.addBlooms(task.bloomReward);

      // Reload
      final active = await _taskService.getActiveTasks();
      final completed = await _taskService.getCompletedTasks();
      
      if (state is TaskLoaded) {
        final reloaded = state as TaskLoaded;
        emit(reloaded.copyWith(
          activeTasks: active,
          completedTasks: completed,
        ));
      } else {
        await loadTasks();
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // ── Delete ─────────────────────────────────

  Future<void> deleteTask(String id) async {
    if (state is! TaskLoaded) return;
    final current = state as TaskLoaded;

    try {
      // Stop timer if it was running for this task
      if (current.activeTimerTaskId == id) {
        stopTimer();
      }

      await _taskService.deleteTask(id);

      // Reload
      final active = await _taskService.getActiveTasks();
      final completed = await _taskService.getCompletedTasks();
      
      if (state is TaskLoaded) {
        final reloaded = state as TaskLoaded;
        emit(reloaded.copyWith(
          activeTasks: active,
          completedTasks: completed,
        ));
      } else {
        await loadTasks();
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // ── Timer Logic ────────────────────────────

  void startTimer(String taskId) {
    if (state is! TaskLoaded) return;
    final current = state as TaskLoaded;

    // Stop current running timer if any
    _timer?.cancel();

    emit(current.copyWith(
      activeTimerTaskId: () => taskId,
      timerSeconds: 0,
    ));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is TaskLoaded) {
        final s = state as TaskLoaded;
        emit(s.copyWith(timerSeconds: s.timerSeconds + 1));
      } else {
        timer.cancel();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
  }

  void resumeTimer() {
    if (state is! TaskLoaded) return;
    final current = state as TaskLoaded;
    if (current.activeTimerTaskId == null) return;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is TaskLoaded) {
        final s = state as TaskLoaded;
        emit(s.copyWith(timerSeconds: s.timerSeconds + 1));
      } else {
        timer.cancel();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    if (state is TaskLoaded) {
      final current = state as TaskLoaded;
      emit(current.copyWith(
        activeTimerTaskId: () => null,
        timerSeconds: 0,
      ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
