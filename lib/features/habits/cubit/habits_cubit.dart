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

  /// Habit IDs with an in-flight [toggleHabitComplete] call. Guards against
  /// double-tap/rapid-tap races: since no new state is emitted until all
  /// the async DB writes + XP award finish, a second tap before that would
  /// otherwise see the same stale "not yet done" state and award XP twice.
  final Set<String> _pendingToggles = {};

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
    if (!_pendingToggles.add(habitId)) {
      return; // Already processing a tap for this habit — ignore the duplicate.
    }
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
    } finally {
      _pendingToggles.remove(habitId);
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

  /// Overall "perfect day" streak: consecutive calendar days (ending today
  /// or yesterday, same leniency rule as per-habit streaks) on which
  /// *every* active habit was completed. This is computed on the fly from
  /// existing habit logs — it supersedes the legacy `UserModel.streakDays`
  /// field, which was never actually updated anywhere and always read 0.
  int get overallStreak {
    if (state is! HabitsLoaded) return 0;
    final loaded = state as HabitsLoaded;
    if (loaded.habits.isEmpty) return 0;

    final perHabitDayKeys = loaded.habits.map((h) {
      final dates = loaded.habitLogs[h.id] ?? <DateTime>[];
      return dates.map((d) => '${d.year}-${d.month}-${d.day}').toSet();
    }).toList();

    // Any habit with zero completions ever means there's no "perfect day" yet.
    if (perHabitDayKeys.any((s) => s.isEmpty)) return 0;

    var commonDays = perHabitDayKeys.first;
    for (final s in perHabitDayKeys.skip(1)) {
      commonDays = commonDays.intersection(s);
    }
    if (commonDays.isEmpty) return 0;

    final perfectDays = commonDays.map((key) {
      final parts = key.split('-').map(int.parse).toList();
      return DateTime(parts[0], parts[1], parts[2]);
    }).toList();

    return StreakCalculator.calculate(perfectDays).current;
  }
}
