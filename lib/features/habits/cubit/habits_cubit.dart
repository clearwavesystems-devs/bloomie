import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/streak_calculator.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../services/habit_service.dart';
import 'habits_state.dart';

class HabitsCubit extends Cubit<HabitsState> {
  final HabitService _habitService;
  final ProfileCubit _profileCubit;

  HabitsCubit(this._habitService, this._profileCubit)
      : super(HabitsInitial());

  // ── Load ───────────────────────────────────

  Future<void> loadHabits() async {
    emit(HabitsLoading());
    try {
      final habits = await _habitService.getAllHabits();
      final loadedState = await _buildLoadedState(habits);
      emit(loadedState);
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  /// Builds a fully-enriched [HabitsLoaded] state with streaks, logs, and
  /// today's XP/completion stats from the database.
  Future<HabitsLoaded> _buildLoadedState(List<Habit> habits) async {
    final today = DateTime.now();
    final Map<String, List<DateTime>> allLogs = {};

    int todayXpEarned = 0;
    int completedToday = 0;

    for (final habit in habits) {
      final logs = await _habitService.getLogsForHabit(habit.id);
      final dates = logs.map((l) => l.completedAt).toList();
      allLogs[habit.id] = dates;

      // Count completions today
      final todayLogs = logs.where(
          (l) => StreakCalculator.isToday(l.completedAt));
      if (todayLogs.isNotEmpty) {
        completedToday++;
        todayXpEarned += habit.xpReward;
      }
    }

    final todayRate =
        habits.isNotEmpty ? completedToday / habits.length : 0.0;

    return HabitsLoaded(
      habits: habits,
      selectedDate: today,
      habitLogs: allLogs,
      todayCompletionRate: todayRate,
      todayXpEarned: todayXpEarned,
    );
  }

  // ── Add ────────────────────────────────────

  Future<void> addHabit(Habit habit) async {
    try {
      await _habitService.saveHabit(habit);
      await loadHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  // ── Toggle Complete ────────────────────────

  Future<void> toggleHabitComplete(String habitId) async {
    if (state is! HabitsLoaded) return;
    final currentState = state as HabitsLoaded;

    try {
      final habit = currentState.habits.firstWhere((h) => h.id == habitId);

      // Guard: already completed today?
      final todayLogs =
          (currentState.habitLogs[habitId] ?? []).where(StreakCalculator.isToday);
      if (todayLogs.isNotEmpty) return;

      // Optimistic UI update — increment count immediately.
      final now = DateTime.now();
      final newCount = habit.currentCount + 1;

      // Recalculate streak from logs + today.
      final List<DateTime> allDates = [
        ...(currentState.habitLogs[habitId] ?? []),
        now,
      ];
      final streakResult = StreakCalculator.calculate(allDates);

      final updatedHabit = habit.copyWith(
        currentCount: newCount,
        streakCount: streakResult.current,
        longestStreak: streakResult.longest,
        lastCompletedAt: Value(now),
      );

      await _habitService.updateHabit(updatedHabit);
      await _habitService.logCompletion(HabitLog(
        id: '${habitId}_${now.millisecondsSinceEpoch}',
        habitId: habitId,
        completedAt: now,
        count: 1,
      ));

      // Award XP via ProfileCubit (single source of truth).
      await _profileCubit.addXP(habit.xpReward);

      // Check if ALL habits are done today → bonus blooms.
      final updatedHabits = currentState.habits.map((h) {
        return h.id == habitId ? updatedHabit : h;
      }).toList();
      final allDoneToday = updatedHabits
          .every((h) => h.id == habitId || _isDoneToday(currentState, h.id));

      if (allDoneToday && updatedHabits.isNotEmpty) {
        await _profileCubit.addBlooms(50); // All-habits-complete bonus
      }

      await loadHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  bool _isDoneToday(HabitsLoaded state, String habitId) {
    final logs = state.habitLogs[habitId] ?? [];
    return logs.any(StreakCalculator.isToday);
  }

  // ── Archive ────────────────────────────────

  Future<void> archiveHabit(String habitId) async {
    try {
      await _habitService.archiveHabit(habitId);
      await loadHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  // ── Update ─────────────────────────────────

  Future<void> updateHabit(Habit habit) async {
    try {
      await _habitService.updateHabit(habit);
      await loadHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  // ── Streak helpers (public for UI) ─────────

  /// Returns current streak for [habitId] computed from cached logs.
  int currentStreakFor(String habitId) {
    if (state is! HabitsLoaded) return 0;
    final dates = (state as HabitsLoaded).habitLogs[habitId] ?? [];
    return StreakCalculator.calculate(dates).current;
  }

  /// Returns longest streak for [habitId] computed from cached logs.
  int longestStreakFor(String habitId) {
    if (state is! HabitsLoaded) return 0;
    final dates = (state as HabitsLoaded).habitLogs[habitId] ?? [];
    return StreakCalculator.calculate(dates).longest;
  }

  /// Whether [habitId] has been completed today.
  bool isCompletedToday(String habitId) {
    if (state is! HabitsLoaded) return false;
    final logs = (state as HabitsLoaded).habitLogs[habitId] ?? [];
    return logs.any(StreakCalculator.isToday);
  }
}
