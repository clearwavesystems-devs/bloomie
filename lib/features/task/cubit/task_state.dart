import 'package:equatable/equatable.dart';
import '../../../core/database/app_database.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> activeTasks;
  final List<Task> completedTasks;
  final String? activeTimerTaskId;
  final int timerSeconds;

  const TaskLoaded({
    required this.activeTasks,
    required this.completedTasks,
    this.activeTimerTaskId,
    this.timerSeconds = 0,
  });

  TaskLoaded copyWith({
    List<Task>? activeTasks,
    List<Task>? completedTasks,
    String? Function()? activeTimerTaskId,
    int? timerSeconds,
  }) {
    return TaskLoaded(
      activeTasks: activeTasks ?? this.activeTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      activeTimerTaskId: activeTimerTaskId != null ? activeTimerTaskId() : this.activeTimerTaskId,
      timerSeconds: timerSeconds ?? this.timerSeconds,
    );
  }

  @override
  List<Object?> get props => [activeTasks, completedTasks, activeTimerTaskId, timerSeconds];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
