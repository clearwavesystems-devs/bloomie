import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../services/garden_service.dart';
import 'garden_state.dart';

class GardenCubit extends Cubit<GardenState> {
  final GardenService _gardenService;
  final ProfileCubit _profileCubit;

  GardenCubit(this._gardenService, this._profileCubit)
      : super(GardenInitial());

  // ── Init (auto-detect solo or duo) ─────────

  Future<void> init() async {
    final session = await _gardenService.getActiveSession();
    if (session != null) {
      await loadDuoGarden(session.id);
    } else {
      await loadSoloGarden();
    }
  }

  // ── Solo Garden ────────────────────────────

  Future<void> loadSoloGarden() async {
    emit(GardenLoading());
    try {
      var activePlant = await _gardenService.getActiveSoloPlant();
      final allPlants = await _gardenService.getSoloPlants();

      // First-time: create a starter plant.
      if (activePlant == null && allPlants.isEmpty) {
        activePlant = await _createStarterPlant();
      } else if (activePlant == null && allPlants.isNotEmpty) {
        // All plants are at stage 4 — create a new one.
        activePlant = await _createStarterPlant();
      }

      final updatedAll = await _gardenService.getSoloPlants();
      emit(GardenLoaded(activePlant: activePlant!, allPlants: updatedAll));
    } catch (e) {
      emit(GardenError(e.toString()));
    }
  }

  /// Called by HabitsCubit (or AppShell listener) after habits are completed.
  /// [completionRate] is 0.0–1.0 from HabitsLoaded.todayCompletionRate.
  Future<void> onHabitsCompleted(double completionRate) async {
    if (state is! GardenLoaded) return;
    final current = state as GardenLoaded;

    try {
      final didLevelUp = await _gardenService.applyDailyGrowth(
          current.activePlant.id, completionRate);

      int bloomsAwarded = 0;
      if (didLevelUp) {
        bloomsAwarded = 200;
        await _profileCubit.addXP(200);
        await _profileCubit.addBlooms(200);
      }

      final updatedPlant = await _gardenService.getActiveSoloPlant();
      final updatedAll = await _gardenService.getSoloPlants();

      // If plant is fully grown, prepare a new slot.
      final nextActivePlant = updatedPlant ??
          (await _createStarterPlant());

      emit(GardenLoaded(
        activePlant: nextActivePlant,
        allPlants: updatedAll,
        justLeveledUp: didLevelUp,
        bloomsJustAwarded: bloomsAwarded,
      ));
    } catch (e) {
      emit(GardenError(e.toString()));
    }
  }

  // ── Duo Garden ─────────────────────────────

  Future<void> loadDuoGarden(String duoSessionId) async {
    emit(GardenLoading());
    try {
      final plant = await _gardenService.getPlantForDuo(duoSessionId);
      final allPlants = await _gardenService.getAllUnlockedPlants();

      // Filter out seed/stale plants from other sessions/inactive defaults
      final filteredPlants = allPlants.where((p) =>
        p.ownerId == 'me' ||
        p.duoSessionId == duoSessionId ||
        (plant != null && p.id == plant.id)
      ).toList();

      // Deduplicate by ID to guarantee single entries
      final uniquePlants = <String, Plant>{};
      for (final p in filteredPlants) {
        uniquePlants[p.id] = p;
      }
      final finalPlants = uniquePlants.values.toList();

      if (plant != null) {
        emit(GardenLoaded(activePlant: plant, allPlants: finalPlants));
      } else if (finalPlants.isNotEmpty) {
        emit(GardenLoaded(activePlant: finalPlants.first, allPlants: finalPlants));
      } else {
        emit(const GardenError(
            'Your garden is empty! Start completing habits to grow plants.'));
      }
    } catch (e) {
      emit(GardenError(e.toString()));
    }
  }

  Future<void> waterDuoPlant(String plantId, String duoSessionId) async {
    try {
      final didLevelUp = await _gardenService.waterPlant(plantId);
      if (didLevelUp) {
        await _profileCubit.addXP(100);
        await _profileCubit.addBlooms(100);
      }
      await loadDuoGarden(duoSessionId);
    } catch (e) {
      emit(GardenError(e.toString()));
    }
  }

  // ── Select plant from collection ───────────

  void selectPlant(Plant plant) {
    if (state is GardenLoaded) {
      final current = state as GardenLoaded;
      emit(current.copyWith(activePlant: plant));
    }
  }

  // ── Internal ───────────────────────────────

  Future<Plant> _createStarterPlant() async {
    const starterPlants = [
      ('🌱', 'Little Sprout'),
      ('🌷', 'Pink Tulip'),
      ('🌺', 'Hibiscus'),
      ('🌻', 'Sunflower'),
      ('🪷', 'Lotus'),
      ('🌹', 'Eternal Rose'),
    ];

    final allPlants = await _gardenService.getSoloPlants();
    final idx = allPlants.length % starterPlants.length;
    final (emoji, name) = starterPlants[idx];

    final newPlant = Plant(
      id: const Uuid().v4(),
      name: name,
      emoji: emoji,
      stage: 0,
      growthPercent: 0.0,
      ownerId: 'me',
      waterCount: 0,
      unlockedAt: DateTime.now(),
    );

    await _gardenService.createSoloPlant(newPlant);
    return newPlant;
  }
}

// Helper extension so GardenLoaded keeps old `currentPlant` API working
// during the transition — avoids breaking existing duo screen.
extension GardenLoadedCompat on GardenLoaded {
  Plant get currentPlant => activePlant;
  List<Plant> get history => allPlants;
}
