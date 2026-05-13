import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/duo_service.dart';
import 'duo_state.dart';

class DuoCubit extends Cubit<DuoState> {
  final DuoService _duoService;

  DuoCubit(this._duoService) : super(DuoInitial());

  Future<void> loadDuoData() async {
    emit(DuoLoading());
    try {
      final session = await _duoService.getActiveSession();
      final partner = _duoService.getPartnerStatus();
      final report = _duoService.getWeeklyReport();
      emit(DuoLoaded(session: session, partner: partner, weeklyReport: report));
    } catch (e) {
      emit(DuoError(e.toString()));
    }
  }

  Future<void> sendPetal() async {
    // Simulated petal event
    print('Petal sent!');
  }
}
