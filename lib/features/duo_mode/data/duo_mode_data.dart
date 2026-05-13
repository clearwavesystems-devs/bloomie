// Data models and mock data for Bloomie Duo Mode

class HabitModel {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final String partnerBadge;
  bool isCompleted;
  bool partnerCompleted;
  final int streakDays;

  HabitModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.partnerBadge,
    this.isCompleted = false,
    this.partnerCompleted = false,
    this.streakDays = 0,
  });

  HabitModel copyWith({bool? isCompleted, bool? partnerCompleted}) {
    return HabitModel(
      id: id,
      title: title,
      subtitle: subtitle,
      emoji: emoji,
      partnerBadge: partnerBadge,
      isCompleted: isCompleted ?? this.isCompleted,
      partnerCompleted: partnerCompleted ?? this.partnerCompleted,
      streakDays: streakDays,
    );
  }
}

class WeeklyReportDay {
  final String day;
  final double myProgress;
  final double partnerProgress;

  const WeeklyReportDay({
    required this.day,
    required this.myProgress,
    required this.partnerProgress,
  });
}

class DuoModeData {
  static List<HabitModel> habits = [
    HabitModel(
      id: '1',
      title: 'Morning Stretch',
      subtitle: '10 mins · Every day',
      emoji: '🧘',
      partnerBadge: 'Lily did this ✓',
      isCompleted: true,
      partnerCompleted: true,
      streakDays: 7,
    ),
    HabitModel(
      id: '2',
      title: 'Drink 8 Glasses',
      subtitle: 'Hydration · Daily goal',
      emoji: '💧',
      partnerBadge: 'Lily is on it 💪',
      isCompleted: false,
      partnerCompleted: false,
      streakDays: 4,
    ),
    HabitModel(
      id: '3',
      title: 'Read Together',
      subtitle: '20 mins · Evening',
      emoji: '📖',
      partnerBadge: 'Lily waiting for you!',
      isCompleted: false,
      partnerCompleted: true,
      streakDays: 12,
    ),
    HabitModel(
      id: '4',
      title: 'Gratitude Journal',
      subtitle: '5 mins · Bedtime',
      emoji: '✍️',
      partnerBadge: 'Lily completed ✓',
      isCompleted: true,
      partnerCompleted: true,
      streakDays: 21,
    ),
    HabitModel(
      id: '5',
      title: 'Evening Walk',
      subtitle: '30 mins · Outdoors',
      emoji: '🚶',
      partnerBadge: 'Lily skipped today',
      isCompleted: false,
      partnerCompleted: false,
      streakDays: 3,
    ),
  ];

  static const List<WeeklyReportDay> weeklyReport = [
    WeeklyReportDay(day: 'Mon', myProgress: 0.85, partnerProgress: 0.90),
    WeeklyReportDay(day: 'Tue', myProgress: 0.60, partnerProgress: 0.75),
    WeeklyReportDay(day: 'Wed', myProgress: 0.95, partnerProgress: 0.80),
    WeeklyReportDay(day: 'Thu', myProgress: 0.70, partnerProgress: 0.65),
    WeeklyReportDay(day: 'Fri', myProgress: 0.80, partnerProgress: 0.85),
    WeeklyReportDay(day: 'Sat', myProgress: 0.50, partnerProgress: 0.95),
    WeeklyReportDay(day: 'Sun', myProgress: 1.0, partnerProgress: 0.70),
  ];
}
