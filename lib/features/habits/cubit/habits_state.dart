import 'package:equatable/equatable.dart';
import '../../../core/database/app_database.dart';

abstract class HabitsState extends Equatable {
  const HabitsState();

  @override
  List<Object?> get props => [];
}

class HabitsInitial extends HabitsState {}

class HabitsLoading extends HabitsState {}

class HabitsLoaded extends HabitsState {
  final List<Habit> habits;
  final DateTime selectedDate;

  /// Map of habitId → list of completion dates (for streak display per card)
  final Map<String, List<DateTime>> habitLogs;

  /// 0.0–1.0 — ratio of habits completed today
  final double todayCompletionRate;

  /// Total XP earned from habits today
  final int todayXpEarned;

  const HabitsLoaded({
    required this.habits,
    required this.selectedDate,
    this.habitLogs = const {},
    this.todayCompletionRate = 0.0,
    this.todayXpEarned = 0,
  });

  HabitsLoaded copyWith({
    List<Habit>? habits,
    DateTime? selectedDate,
    Map<String, List<DateTime>>? habitLogs,
    double? todayCompletionRate,
    int? todayXpEarned,
  }) {
    return HabitsLoaded(
      habits: habits ?? this.habits,
      selectedDate: selectedDate ?? this.selectedDate,
      habitLogs: habitLogs ?? this.habitLogs,
      todayCompletionRate: todayCompletionRate ?? this.todayCompletionRate,
      todayXpEarned: todayXpEarned ?? this.todayXpEarned,
    );
  }

  @override
  List<Object?> get props =>
      [habits, selectedDate, habitLogs, todayCompletionRate, todayXpEarned];
}

class HabitsError extends HabitsState {
  final String message;

  const HabitsError(this.message);

  @override
  List<Object?> get props => [message];
}
