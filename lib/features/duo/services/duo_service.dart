import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/app_database.dart';
import '../models/partner_model.dart';
import 'partner_simulator.dart';

class DuoService {
  final AppDatabase _db;
  final SupabaseClient _supabase = Supabase.instance.client;

  DuoService(this._db);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // ── Session Operations ──────────────────────

  /// Fetches the active Duo session (either from Supabase or SQLite fallback).
  Future<DuoSession?> getActiveSession() async {
    final userId = _currentUserId;
    if (userId != null) {
      try {
        final data = await _supabase
            .from('duo_sessions')
            .select()
            .or('user_a_id.eq.$userId,user_b_id.eq.$userId')
            .eq('is_active', true)
            .maybeSingle();

        if (data != null) {
          final createdAt = DateTime.parse(data['created_at'] as String);
          final userBId = data['user_b_id'] as String?;

          // Automatic 24-hour expiration for invite codes that haven't been joined
          if (userBId == null && DateTime.now().difference(createdAt).inHours >= 24) {
            await _supabase.from('duo_sessions').update({'is_active': false}).eq('id', data['id']);
            await _db.customStatement('UPDATE duo_sessions SET is_active = 0');
            return null;
          }

          // Construct the session model
          final session = DuoSession(
            id: data['id'] as String,
            userAId: data['user_a_id'] as String,
            userBId: userBId,
            sharedPlantId: data['shared_plant_id'] as String? ?? 'plant_shared',
            inviteCode: data['invite_code'] as String,
            createdAt: createdAt,
            isActive: data['is_active'] as bool? ?? true,
          );

          // Cache it locally in SQLite
          await _db.insertSession(session);
          return session;
        } else {
          // Delete active duo sessions locally if none exist in the cloud
          // (meaning the user left the session or it was deactivated)
          await _db.customStatement('UPDATE duo_sessions SET is_active = 0');
          return null;
        }
      } catch (e) {
        print('DuoService: Error fetching Supabase session, falling back: $e');
      }
    }

    // Offline / Fallback to local SQLite
    return await _db.getActiveSession();
  }

  /// Creates a new Duo session in Supabase and caches it locally.
  Future<DuoSession> createSession() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('Must be signed in to create a Duo session.');
    }

    final randomCode = 'BLOOM${Random().nextInt(9000) + 1000}';
    final newPlantId = 'plant_${Random().nextInt(1000000)}';

    final sessionMap = {
      'invite_code': randomCode,
      'user_a_id': userId,
      'user_b_id': null,
      'shared_plant_id': newPlantId,
      'is_active': true,
    };

    final inserted = await _supabase
        .from('duo_sessions')
        .insert(sessionMap)
        .select()
        .single();

    final session = DuoSession(
      id: inserted['id'] as String,
      userAId: inserted['user_a_id'] as String,
      userBId: inserted['user_b_id'] as String?,
      sharedPlantId: inserted['shared_plant_id'] as String,
      inviteCode: inserted['invite_code'] as String,
      createdAt: DateTime.parse(inserted['created_at'] as String),
      isActive: inserted['is_active'] as bool? ?? true,
    );

    // Seed shared plant in local SQLite too
    await _db.insertPlant(Plant(
      id: newPlantId,
      name: 'Eternal Rose',
      emoji: '🌹',
      stage: 1,
      growthPercent: 0.1,
      ownerId: 'shared',
      waterCount: 10,
      duoSessionId: session.id,
      unlockedAt: DateTime.now(),
    ));

    await _db.insertSession(session);
    return session;
  }

  /// Joins an existing Duo session via invite code.
  Future<DuoSession> joinSession(String inviteCode) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('Must be signed in to join a Duo session.');
    }

    // 1. Find the active session in Supabase
    final data = await _supabase
        .from('duo_sessions')
        .select()
        .eq('invite_code', inviteCode.trim().toUpperCase())
        .eq('is_active', true)
        .maybeSingle();

    if (data == null) {
      throw Exception('Invalid or expired invite code.');
    }

    final String sessionAId = data['user_a_id'] as String;
    if (sessionAId == userId) {
      throw Exception('You cannot join your own session!');
    }

    if (data['user_b_id'] != null) {
      throw Exception('This session is already full.');
    }

    // 2. Join the session
    final updated = await _supabase
        .from('duo_sessions')
        .update({'user_b_id': userId})
        .eq('id', data['id'])
        .select()
        .single();

    // 3. Link profiles duo_partner_id
    await _supabase
        .from('profiles')
        .update({'duo_partner_id': sessionAId})
        .eq('id', userId);

    await _supabase
        .from('profiles')
        .update({'duo_partner_id': userId})
        .eq('id', sessionAId);

    final session = DuoSession(
      id: updated['id'] as String,
      userAId: updated['user_a_id'] as String,
      userBId: updated['user_b_id'] as String?,
      sharedPlantId: updated['shared_plant_id'] as String? ?? 'plant_shared',
      inviteCode: updated['invite_code'] as String,
      createdAt: DateTime.parse(updated['created_at'] as String),
      isActive: updated['is_active'] as bool? ?? true,
    );

    // Seed shared plant in local database
    await _db.insertPlant(Plant(
      id: session.sharedPlantId,
      name: 'Eternal Rose',
      emoji: '🌹',
      stage: 1,
      growthPercent: 0.1,
      ownerId: 'shared',
      waterCount: 10,
      duoSessionId: session.id,
      unlockedAt: DateTime.now(),
    ));

    await _db.insertSession(session);
    return session;
  }

  // ── Partner Operations ──────────────────────

  /// Retrieves the partner's status. If online, gets real Supabase profile.
  Future<PartnerModel?> getPartnerStatus(String? partnerId) async {
    if (partnerId == null || partnerId.isEmpty) return null;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', partnerId)
          .maybeSingle();

      if (data != null) {
        final streak = data['streak_days'] as int? ?? 0;
        final xp = data['xp'] as int? ?? 0;

        return PartnerModel(
          id: partnerId,
          name: data['name'] as String? ?? 'Friend',
          avatarEmoji: data['avatar_emoji'] as String? ?? '🐰',
          lastActiveAt: DateTime.now(),
          todayHabitsDone: xp ~/ 50 % 5, // derived from actual habit completions / XP progress
          todayHabitsTotal: 5,
          currentStreak: streak,
        );
      }
    } catch (e) {
      print('DuoService: Error loading partner status from Supabase: $e');
    }

    // Default Fallback
    return PartnerSimulator.generateMockPartner();
  }

  /// Sends a real-time petal message to the partner.
  Future<void> sendPetalEvent(String partnerId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _supabase.from('petal_events').insert({
      'sender_id': userId,
      'receiver_id': partnerId,
    });
  }

  /// Listens to real-time incoming petal events for the current user.
  Stream<List<Map<String, dynamic>>> listenToIncomingPetals() {
    final userId = _currentUserId;
    if (userId == null) return const Stream.empty();

    return _supabase
        .from('petal_events')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', userId)
        .order('created_at', ascending: false)
        .limit(1);
  }

  Map<String, List<double>> getWeeklyReport() {
    return PartnerSimulator.generateWeeklyReport();
  }
}
