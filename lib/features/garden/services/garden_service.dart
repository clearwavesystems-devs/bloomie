import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

/// Drives plant growth based on daily habit completion rate.
///
/// Growth per day = [completionRate] × 5 (max 5% per day → ~20 days to full).
/// Stage thresholds: Seed 0–19%, Sprout 20–39%, Bud 40–59%, Bloom 60–89%, Garden 90–100%.
class GrowthEngine {
  static const double _maxDailyGrowth = 0.05;

  static int stageFor(double growthPercent) {
    if (growthPercent < 0.20) return 0; // Seed
    if (growthPercent < 0.40) return 1; // Sprout
    if (growthPercent < 0.60) return 2; // Bud
    if (growthPercent < 0.90) return 3; // Bloom
    return 4; // Garden (complete)
  }

  static String stageLabel(int stage) {
    const labels = ['Seed', 'Sprout', 'Bud', 'Bloom', 'Garden'];
    return labels.clamp(0, 4)[stage];
  }

  static double growthDelta(double completionRate) =>
      _maxDailyGrowth * completionRate.clamp(0.0, 1.0);
}

extension on List<String> {
  List<String> clamp(int min, int max) => sublist(min, max + 1);
}

// ─────────────────────────────────────────────

class GardenService {
  final AppDatabase _db;

  GardenService(this._db);

  // ── Session (duo) ──────────────────────────

  Future<DuoSession?> getActiveSession() => _db.getActiveSession();

  Future<Plant?> getPlantForDuo(String duoSessionId) =>
      _db.getPlantForDuo(duoSessionId);

  // ── Solo garden ────────────────────────────

  Future<Plant?> getActiveSoloPlant() => _db.getActiveSoloPlant();

  Future<List<Plant>> getSoloPlants() => _db.getSoloPlants();

  Future<void> createSoloPlant(Plant plant) async {
    await _db.insertPlant(plant);
  }

  // ── Growth ─────────────────────────────────

  /// Apply one day's growth to a plant based on today's habit [completionRate].
  /// Returns true if the plant reached a new stage (for animation triggers).
  Future<bool> applyDailyGrowth(
      String plantId, double completionRate) async {
    final plant = await _getPlant(plantId);
    if (plant == null || plant.stage >= 4) return false;

    final oldStage = plant.stage;
    final delta = GrowthEngine.growthDelta(completionRate);
    final newGrowth = (plant.growthPercent + delta).clamp(0.0, 1.0);
    final newStage = GrowthEngine.stageFor(newGrowth);

    final updated = plant.copyWith(
      growthPercent: newGrowth,
      stage: newStage,
      waterCount: plant.waterCount + 1,
      lastWateredAt: Value(DateTime.now()),
      unlockedAt: newStage == 4 ? Value(DateTime.now()) : Value(plant.unlockedAt),
    );

    await _db.updatePlant(updated);
    return newStage > oldStage;
  }

  // ── Water (duo) ────────────────────────────

  Future<bool> waterPlant(String plantId) async {
    final plant = await _getPlant(plantId);
    if (plant == null) return false;

    final oldStage = plant.stage;
    final newWaterCount = plant.waterCount + 1;
    final newGrowthPercent = (newWaterCount / 100).clamp(0.0, 1.0);
    final newStage = GrowthEngine.stageFor(newGrowthPercent);

    final updatedPlant = plant.copyWith(
      waterCount: newWaterCount,
      growthPercent: newGrowthPercent,
      stage: newStage,
      lastWateredAt: Value(DateTime.now()),
    );

    await _db.updatePlant(updatedPlant);
    return newStage > oldStage;
  }

  Future<List<Plant>> getAllUnlockedPlants() => _db.getAllPlants();

  // ── Internal ───────────────────────────────

  Future<Plant?> _getPlant(String plantId) =>
      (_db.select(_db.plants)..where((t) => t.id.equals(plantId)))
          .getSingleOrNull();
}
