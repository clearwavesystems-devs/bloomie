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

  const HabitsLoaded({
    required this.habits,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [habits, selectedDate];
}

class HabitsError extends HabitsState {
  final String message;

  const HabitsError(this.message);

  @override
  List<Object?> get props => [message];
}
