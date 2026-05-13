import 'package:equatable/equatable.dart';

class TaskItem extends Equatable {
  final String title;
  final bool completed;
  final String? time;
  final int xpReward;

  const TaskItem({
    required this.title,
    this.completed = false,
    this.time,
    this.xpReward = 20,
  });

  TaskItem copyWith({bool? completed, String? title, String? time}) {
    return TaskItem(
      title: title ?? this.title,
      completed: completed ?? this.completed,
      time: time ?? this.time,
      xpReward: xpReward,
    );
  }

  @override
  List<Object?> get props => [title, completed, time, xpReward];
}

class JournalEntry extends Equatable {
  final String text;
  final String mood;
  final DateTime date;

  const JournalEntry({
    required this.text,
    required this.mood,
    required this.date,
  });

  @override
  List<Object?> get props => [text, mood, date];
}

class ShopItem extends Equatable {
  final String name;
  final String emoji;
  final int price;
  final String category;
  final bool owned;

  const ShopItem({
    required this.name,
    required this.emoji,
    required this.price,
    required this.category,
    this.owned = false,
  });

  ShopItem copyWith({bool? owned}) => ShopItem(
        name: name,
        emoji: emoji,
        price: price,
        category: category,
        owned: owned ?? this.owned,
      );

  @override
  List<Object?> get props => [name, emoji, price, category, owned];
}

class PetAccessory extends Equatable {
  final String name;
  final String emoji;
  final bool equipped;

  const PetAccessory({
    required this.name,
    required this.emoji,
    this.equipped = false,
  });

  @override
  List<Object?> get props => [name, emoji, equipped];
}

class AdventureLand extends Equatable {
  final String name;
  final String emoji;
  final int requiredLevel;
  final bool unlocked;
  final double progress;

  const AdventureLand({
    required this.name,
    required this.emoji,
    required this.requiredLevel,
    this.unlocked = false,
    this.progress = 0,
  });

  @override
  List<Object?> get props => [name, emoji, requiredLevel, unlocked, progress];
}

class StreakRecord extends Equatable {
  final String day;
  final int value;
  final int maxValue;

  const StreakRecord({
    required this.day,
    required this.value,
    required this.maxValue,
  });

  @override
  List<Object?> get props => [day, value, maxValue];
}