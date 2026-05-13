import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

class GardenService {
  final AppDatabase _db;

  GardenService(this._db);

  Future<Plant?> getPlantForDuo(String duoSessionId) => _db.getPlantForDuo(duoSessionId);

  Future<void> waterPlant(String plantId) async {
    final plant = await (_db.select(_db.plants)..where((t) => t.id.equals(plantId))).getSingleOrNull();
    if (plant != null) {
      final newWaterCount = plant.waterCount + 1;
      final newGrowthPercent = (newWaterCount / 100).clamp(0.0, 1.0);
      
      int newStage = 0;
      if (newGrowthPercent < 0.2) {
        newStage = 0; // Seed
      } else if (newGrowthPercent < 0.4) {
        newStage = 1; // Sprout
      } else if (newGrowthPercent < 0.6) {
        newStage = 2; // Bud
      } else if (newGrowthPercent < 0.9) {
        newStage = 3; // Bloom
      } else {
        newStage = 4; // Garden
      }

      final updatedPlant = plant.copyWith(
        waterCount: newWaterCount,
        growthPercent: newGrowthPercent,
        stage: newStage,
        lastWateredAt: Value(DateTime.now()),
      );
      
      await _db.updatePlant(updatedPlant);
    }
  }

  Future<List<Plant>> getAllUnlockedPlants() => _db.getAllPlants();
}
