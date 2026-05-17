import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/app_database.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';
import 'adventure_state.dart';

class AdventureCubit extends Cubit<AdventureState> {
  final AppDatabase _db;
  final ProfileCubit _profileCubit;

  AdventureCubit(this._db, this._profileCubit) : super(AdventureInitial());

  // ── Load ───────────────────────────────────

  Future<void> loadLands() async {
    emit(AdventureLoading());
    try {
      final lands = await _db.getAllLands();
      final level = _getCurrentLevel();

      // Auto-unlock lands that meet the level requirement
      bool updated = false;
      final updatedLands = <AdventureLand>[];
      for (final land in lands) {
        if (!land.unlocked && land.requiredLevel <= level) {
          final unlocked = land.copyWith(unlocked: true);
          await _db.updateLand(unlocked);
          updatedLands.add(unlocked);
          updated = true;
        } else {
          updatedLands.add(land);
        }
      }

      if (updated) {
        emit(AdventureLoaded(lands: updatedLands, currentLevel: level));
      } else {
        emit(AdventureLoaded(lands: lands, currentLevel: level));
      }
    } catch (e) {
      emit(AdventureError(e.toString()));
    }
  }

  // ── Explore Land (increase progress) ──────

  Future<void> exploreLand(AdventureLand land) async {
    if (state is! AdventureLoaded) return;
    if (!land.unlocked) return;

    // Progress increases by 10% per explore action, capped at 1.0
    final newProgress = (land.progress + 0.1).clamp(0.0, 1.0);
    final updated = land.copyWith(progress: newProgress);
    await _db.updateLand(updated);

    // Award XP for exploring
    await _profileCubit.addXP(30);

    await loadLands();
  }

  // ── Helpers ────────────────────────────────

  int _getCurrentLevel() {
    final profileState = _profileCubit.state;
    if (profileState is ProfileLoaded) {
      return profileState.user.level;
    }
    return 1;
  }

  bool canUnlock(AdventureLand land) {
    return _getCurrentLevel() >= land.requiredLevel;
  }
}
