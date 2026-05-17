/// Pure streak mathematics — no Flutter dependencies.
class StreakCalculator {
  /// Given a list of [HabitLog] completion timestamps, returns the current
  /// streak and the all-time longest streak (in calendar days).
  ///
  /// A streak is maintained when the habit was completed on consecutive
  /// calendar days up to and including today.
  static ({int current, int longest}) calculate(
      List<DateTime> completionDates) {
    if (completionDates.isEmpty) return (current: 0, longest: 0);

    // Deduplicate to one entry per calendar day and sort ascending.
    final days = _uniqueDays(completionDates)..sort();

    int currentStreak = 0;
    int longestStreak = 0;
    int runningStreak = 1;

    for (int i = 1; i < days.length; i++) {
      final diff = days[i].difference(days[i - 1]).inDays;
      if (diff == 1) {
        runningStreak++;
      } else {
        if (runningStreak > longestStreak) longestStreak = runningStreak;
        runningStreak = 1;
      }
    }
    if (runningStreak > longestStreak) longestStreak = runningStreak;

    // Current streak: running only if the last completion was today or yesterday.
    final today = _dayOnly(DateTime.now());
    final lastDay = days.last;
    final gap = today.difference(lastDay).inDays;

    if (gap == 0 || gap == 1) {
      // Walk backwards from the end to find the current run length.
      currentStreak = 1;
      for (int i = days.length - 2; i >= 0; i--) {
        final diff = days[i + 1].difference(days[i]).inDays;
        if (diff == 1) {
          currentStreak++;
        } else {
          break;
        }
      }
    } else {
      currentStreak = 0;
    }

    return (current: currentStreak, longest: longestStreak);
  }

  /// Returns whether [date] falls on the same calendar day as today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Truncate a [DateTime] to midnight (year-month-day only).
  static DateTime _dayOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// Returns a deduplicated list of calendar days from [dates].
  static List<DateTime> _uniqueDays(List<DateTime> dates) {
    final seen = <String>{};
    final result = <DateTime>[];
    for (final d in dates) {
      final key = '${d.year}-${d.month}-${d.day}';
      if (seen.add(key)) result.add(_dayOnly(d));
    }
    return result;
  }
}
