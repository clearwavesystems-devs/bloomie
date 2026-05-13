import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/garden_service.dart';
import 'garden_state.dart';

class GardenCubit extends Cubit<GardenState> {
  final GardenService _gardenService;

  GardenCubit(this._gardenService) : super(GardenInitial());
  
  Future<void> init() async {
    final session = await _gardenService.getActiveSession();
    if (session != null) {
      await loadGarden(session.id);
    } else {
      emit(const GardenError('No active duo session found'));
    }
  }
  
  Future<void> loadGarden(String duoSessionId) async {
    emit(GardenLoading());
    try {
      final plant = await _gardenService.getPlantForDuo(duoSessionId);
      final history = await _gardenService.getAllUnlockedPlants();
      
      if (plant != null) {
        emit(GardenLoaded(currentPlant: plant, history: history));
      } else if (history.isNotEmpty) {
        emit(GardenLoaded(currentPlant: history.first, history: history));
      } else {
        emit(const GardenError('Your garden is empty! Start a duo session to grow plants.'));
      }
    } catch (e) {
      emit(GardenError(e.toString()));
    }
  }

  Future<void> waterPlant(String plantId, String duoSessionId) async {
    try {
      await _gardenService.waterPlant(plantId);
      await loadGarden(duoSessionId);
    } catch (e) {
      emit(GardenError(e.toString()));
    }
  }
}
