import 'package:intl/intl.dart';

class BloomieDateUtils {
  static String formatTime(DateTime time) {
    return DateFormat.jm().format(time);
  }

  static String formatDate(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime get startOfDay {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static List<DateTime> get currentWeekDays {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));
  }
}
