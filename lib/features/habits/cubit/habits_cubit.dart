import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/app_database.dart';
import '../services/habit_service.dart';
import 'habits_state.dart';

class HabitsCubit extends Cubit<HabitsState> {
  final HabitService _habitService;

  HabitsCubit(this._habitService) : super(HabitsInitial());

  Future<void> loadHabits() async {
    emit(HabitsLoading());
    try {
      final habits = await _habitService.getAllHabits();
      emit(HabitsLoaded(habits: habits, selectedDate: DateTime.now()));
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      await _habitService.saveHabit(habit);
      await loadHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> toggleHabitComplete(String habitId) async {
    if (state is HabitsLoaded) {
      final currentState = state as HabitsLoaded;
      try {
        final habit = currentState.habits.firstWhere((h) => h.id == habitId);
        final newCount = habit.currentCount + 1;
        
        final updatedHabit = habit.copyWith(currentCount: newCount);
        await _habitService.updateHabit(updatedHabit);
        
        await _habitService.logCompletion(HabitLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          habitId: habitId,
          completedAt: DateTime.now(),
          count: 1,
        ));
        
        await loadHabits();
      } catch (e) {
        emit(HabitsError(e.toString()));
      }
    }
  }

  Future<void> archiveHabit(String habitId) async {
    try {
      await _habitService.archiveHabit(habitId);
      await loadHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }
}
