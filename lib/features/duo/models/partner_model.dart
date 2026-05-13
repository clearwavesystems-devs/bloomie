class PartnerModel {
  final String id;
  final String name;
  final String avatarEmoji;
  final DateTime lastActiveAt;
  final int todayHabitsDone;
  final int todayHabitsTotal;
  final int currentStreak;

  PartnerModel({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.lastActiveAt,
    required this.todayHabitsDone,
    required this.todayHabitsTotal,
    required this.currentStreak,
  });
}
