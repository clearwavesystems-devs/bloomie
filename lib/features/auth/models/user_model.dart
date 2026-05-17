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

  // ── Local (SharedPreferences) ─────────────

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

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  // ── Supabase (cloud) ──────────────────────

  /// Converts to snake_case map for Supabase `profiles` table.
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'name': name,
      'avatar_emoji': avatarEmoji,
      'level': level,
      'xp': xp,
      'total_blooms': totalBlooms,
      'streak_days': streakDays,
      'joined_at': joinedAt.toIso8601String(),
      'duo_partner_id': duoPartnerId,
    };
  }

  /// Creates a UserModel from a Supabase row (snake_case keys).
  factory UserModel.fromSupabase(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      avatarEmoji: map['avatar_emoji'] as String? ?? '🌸',
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      totalBlooms: map['total_blooms'] as int? ?? 0,
      streakDays: map['streak_days'] as int? ?? 0,
      joinedAt: DateTime.parse(map['joined_at'] as String),
      duoPartnerId: map['duo_partner_id'] as String?,
    );
  }
}

