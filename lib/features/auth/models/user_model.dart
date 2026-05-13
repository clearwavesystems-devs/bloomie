import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String avatarEmoji;
  final int level;
  final int xp;
  final int totalBlooms;
  final int streakDays;
  final DateTime joinedAt;
  final String? duoPartnerId;

  UserModel({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    this.level = 1,
    this.xp = 0,
    this.totalBlooms = 0,
    this.streakDays = 0,
    required this.joinedAt,
    this.duoPartnerId,
  });

  UserModel copyWith({
    String? name,
    String? avatarEmoji,
    int? level,
    int? xp,
    int? totalBlooms,
    int? streakDays,
    String? duoPartnerId,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      totalBlooms: totalBlooms ?? this.totalBlooms,
      streakDays: streakDays ?? this.streakDays,
      joinedAt: joinedAt,
      duoPartnerId: duoPartnerId ?? this.duoPartnerId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarEmoji': avatarEmoji,
      'level': level,
      'xp': xp,
      'totalBlooms': totalBlooms,
      'streakDays': streakDays,
      'joinedAt': joinedAt.toIso8601String(),
      'duoPartnerId': duoPartnerId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      avatarEmoji: map['avatarEmoji'],
      level: map['level'],
      xp: map['xp'],
      totalBlooms: map['totalBlooms'],
      streakDays: map['streakDays'],
      joinedAt: DateTime.parse(map['joinedAt']),
      duoPartnerId: map['duoPartnerId'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));
}
