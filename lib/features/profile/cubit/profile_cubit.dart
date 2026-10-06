import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/auth_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  static const String _userKey = 'user_profile';
  final AuthService _authService;

  /// Serializes XP/Blooms read-modify-write operations. Without this,
  /// two near-simultaneous calls (e.g. completing a habit and a task at
  /// the same moment) could both read the same stale balance and one
  /// update would silently overwrite the other (lost-update race).
  Future<void> _mutex = Future.value();

  Future<T> _synchronized<T>(Future<T> Function() action) {
    final result = _mutex.then((_) => action());
    _mutex = result.then((_) {}, onError: (_) {});
    return result;
  }

  ProfileCubit(this._authService) : super(ProfileInitial());

  // ── Load ───────────────────────────────────

  /// Called at startup when there is NO active Supabase session
  /// (offline / first install). Falls back to SharedPreferences.
  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        emit(ProfileLoaded(UserModel.fromJson(userJson)));
      } else {
        final newUser = UserModel(
          id: 'me',
          name: 'Bloomie',
          avatarEmoji: '🌸',
          joinedAt: DateTime.now(),
        );
        await _saveLocally(newUser);
        emit(ProfileLoaded(newUser));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  /// Called by AuthCubit after a successful sign-in or session restore.
  /// Seeds the cubit directly from the cloud profile.
  Future<void> loadFromSupabase(UserModel user) async {
    await _saveLocally(user); // Cache locally so offline works too
    emit(ProfileLoaded(user));
  }

  /// Re-fetches the profile from Supabase (used for manual pull-to-refresh).
  /// Unlike [loadProfile], this doesn't emit [ProfileLoading] first — it
  /// silently keeps the current state if offline/unsigned-in/failed, so it
  /// never causes a loading flicker over an already-displayed profile.
  Future<void> refreshFromCloud() async {
    if (!_authService.isSignedIn) return;
    try {
      final user = await _authService.fetchProfile(_authService.currentUser!.id);
      await loadFromSupabase(user);
    } catch (_) {
      // Offline or network error — keep showing the cached profile.
    }
  }

  /// Returns a previously cached profile for [userId] without touching the
  /// network, or `null` if nothing is cached. Used by [AuthCubit.checkSession]
  /// to keep an already-signed-in user logged in while offline, instead of
  /// forcing them back to the auth screen just because the profile fetch
  /// failed.
  Future<UserModel?> loadCachedProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;

    final cached = UserModel.fromJson(userJson);
    if (cached.id != userId) return null;

    emit(ProfileLoaded(cached));
    return cached;
  }

  // ── Save (dual-write: local + cloud) ───────

  Future<void> saveProfile(UserModel user) async {
    await _saveLocally(user);
    await _saveToCloud(user);
  }

  Future<void> _saveLocally(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toJson());
  }

  Future<void> _saveToCloud(UserModel user) async {
    // Only sync to cloud if a user is signed in
    if (_authService.isSignedIn) {
      await _authService.saveProfile(user);
    }
  }

  // ── XP ─────────────────────────────────────

  Future<void> addXP(int amount) => _synchronized(() async {
        if (state is! ProfileLoaded) return;
        final user = (state as ProfileLoaded).user;
        final newXP = user.xp + amount;
        final newLevel = (newXP ~/ 500) + 1;

        final updated = user.copyWith(xp: newXP, level: newLevel);
        await saveProfile(updated);
        emit(ProfileLoaded(updated));
      });

  // ── Blooms ─────────────────────────────────

  Future<void> addBlooms(int amount) => _synchronized(() async {
        if (state is! ProfileLoaded) return;
        final user = (state as ProfileLoaded).user;
        final updated = user.copyWith(totalBlooms: user.totalBlooms + amount);
        await saveProfile(updated);
        emit(ProfileLoaded(updated));
      });

  Future<bool> deductBlooms(int amount) => _synchronized(() async {
        if (state is! ProfileLoaded) return false;
        final user = (state as ProfileLoaded).user;
        if (user.totalBlooms < amount) return false;

        final updated = user.copyWith(totalBlooms: user.totalBlooms - amount);
        await saveProfile(updated);
        emit(ProfileLoaded(updated));
        return true;
      });

  // ── Helpers ────────────────────────────────

  String getLevelTitle(int level) {
    if (level <= 5) return 'Seedling';
    if (level <= 10) return 'Sprout';
    if (level <= 20) return 'Bloom';
    if (level <= 35) return 'Blossom';
    return 'Garden Master';
  }
}
