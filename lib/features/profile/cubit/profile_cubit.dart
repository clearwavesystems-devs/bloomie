import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/auth_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  static const String _userKey = 'user_profile';
  final AuthService _authService;

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
  void loadFromSupabase(UserModel user) {
    _saveLocally(user); // Cache locally so offline works too
    emit(ProfileLoaded(user));
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

  Future<void> addXP(int amount) async {
    if (state is! ProfileLoaded) return;
    final user = (state as ProfileLoaded).user;
    final newXP = user.xp + amount;
    final newLevel = (newXP ~/ 500) + 1;

    final updated = user.copyWith(xp: newXP, level: newLevel);
    await saveProfile(updated);
    emit(ProfileLoaded(updated));
  }

  // ── Blooms ─────────────────────────────────

  Future<void> addBlooms(int amount) async {
    if (state is! ProfileLoaded) return;
    final user = (state as ProfileLoaded).user;
    final updated = user.copyWith(totalBlooms: user.totalBlooms + amount);
    await saveProfile(updated);
    emit(ProfileLoaded(updated));
  }

  Future<bool> deductBlooms(int amount) async {
    if (state is! ProfileLoaded) return false;
    final user = (state as ProfileLoaded).user;
    if (user.totalBlooms < amount) return false;

    final updated = user.copyWith(totalBlooms: user.totalBlooms - amount);
    await saveProfile(updated);
    emit(ProfileLoaded(updated));
    return true;
  }

  // ── Helpers ────────────────────────────────

  String getLevelTitle(int level) {
    if (level <= 5) return 'Seedling';
    if (level <= 10) return 'Sprout';
    if (level <= 20) return 'Bloom';
    if (level <= 35) return 'Blossom';
    return 'Garden Master';
  }
}
