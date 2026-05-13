import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/models/user_model.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  static const String _userKey = 'user_profile';

  ProfileCubit() : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        emit(ProfileLoaded(UserModel.fromJson(userJson)));
      } else {
        // Initial user
        final newUser = UserModel(
          id: 'me',
          name: 'Alex',
          avatarEmoji: '🌸',
          joinedAt: DateTime.now(),
        );
        await saveProfile(newUser);
        emit(ProfileLoaded(newUser));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> saveProfile(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toJson());
  }

  Future<void> addXP(int amount) async {
    if (state is ProfileLoaded) {
      final user = (state as ProfileLoaded).user;
      final newXP = user.xp + amount;
      final newLevel = (newXP ~/ 500) + 1;
      
      final updatedUser = user.copyWith(xp: newXP, level: newLevel);
      await saveProfile(updatedUser);
      emit(ProfileLoaded(updatedUser));
    }
  }

  Future<void> addBlooms(int amount) async {
    if (state is ProfileLoaded) {
      final user = (state as ProfileLoaded).user;
      final updatedUser = user.copyWith(totalBlooms: user.totalBlooms + amount);
      await saveProfile(updatedUser);
      emit(ProfileLoaded(updatedUser));
    }
  }

  String getLevelTitle(int level) {
    if (level <= 5) return 'Seedling';
    if (level <= 10) return 'Sprout';
    if (level <= 20) return 'Bloom';
    if (level <= 35) return 'Blossom';
    return 'Garden Master';
  }
}
