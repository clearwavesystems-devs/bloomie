import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// Handles all Supabase Auth + profile cloud operations.
class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // ── Auth state ─────────────────────────────

  User? get currentUser => _client.auth.currentUser;
  bool get isSignedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<UserModel> signUp({required String email, required String password, required String displayName}) async {
    try {
      print('AuthService [DEBUG]: Starting signUp for $email');
      final response = await _client.auth.signUp(email: email, password: password);
      print('AuthService [DEBUG]: auth.signUp complete. User ID: ${response.user?.id}');

      final user = response.user;
      if (user == null) throw Exception('Sign up failed — no user returned.');

      // Create cloud profile record
      final newProfile = UserModel(id: user.id, name: displayName, avatarEmoji: '🌸', joinedAt: DateTime.now());

      print('AuthService [DEBUG]: Upserting profile record...');
      await _upsertProfile(newProfile);
      print('AuthService [DEBUG]: Profile upsert complete!');
      return newProfile;
    } catch (e, stack) {
      print('AuthService.signUp Exception: $e');
      print('AuthService.signUp StackTrace: $stack');
      rethrow;
    }
  }

  // ── Sign In ────────────────────────────────

  Future<UserModel> signIn({required String email, required String password}) async {
    final response = await _client.auth.signInWithPassword(email: email, password: password);

    final user = response.user;
    if (user == null) throw Exception('Sign in failed — invalid credentials.');

    return await fetchProfile(user.id);
  }

  // ── Sign Out ───────────────────────────────

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Deletes all user profile data from public tables and signs them out.
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user != null) {
      try {
        // Remove profile from Supabase (cascades to related features)
        await _client.from('profiles').delete().eq('id', user.id);
      } catch (e) {
        print('AuthService.deleteAccount warning: $e');
      }
      await signOut();
    }
  }

  // ── Cloud Profile CRUD ─────────────────────

  /// Fetches profile from Supabase. Falls back to a new default if missing.
  Future<UserModel> fetchProfile(String userId) async {
    final data = await _client.from('profiles').select().eq('id', userId).maybeSingle();

    if (data == null) {
      // First-time login on a new device — create a skeleton profile
      final skeleton = UserModel(
        id: userId,
        name: currentUser?.email?.split('@').first ?? 'Bloomie',
        avatarEmoji: '🌸',
        joinedAt: DateTime.now(),
      );
      await _upsertProfile(skeleton);
      return skeleton;
    }

    return UserModel.fromSupabase(data);
  }

  /// Upserts the profile to Supabase (insert or update).
  Future<void> _upsertProfile(UserModel user) async {
    await _client.from('profiles').upsert(user.toSupabaseMap());
  }

  /// Saves changes to XP, Blooms, level etc. to the cloud.
  Future<void> saveProfile(UserModel user) async {
    await _upsertProfile(user);
  }
}
