import 'package:bloomie/features/duo/services/partner_simulator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/partner_model.dart';
import '../services/duo_service.dart';
import 'duo_state.dart';

class DuoCubit extends Cubit<DuoState> {
  final DuoService _duoService;

  DuoCubit(this._duoService) : super(DuoInitial());

  Future<void> loadDuoData() async {
    emit(DuoLoading());
    try {
      final session = await _duoService.getActiveSession();
      PartnerModel? partner;
      bool isWaitingForPartner = false;
      String? inviteCode;

      if (session != null) {
        final myId = Supabase.instance.client.auth.currentUser?.id;
        final partnerId = session.userAId == myId ? session.userBId : session.userAId;
        if (partnerId != null && partnerId.isNotEmpty) {
          partner = await _duoService.getPartnerStatus(partnerId);
        } else {
          // Active session waiting for partner: initially keep Mira as mock companion
          partner = PartnerSimulator.generateMockPartner();
          isWaitingForPartner = true;
          inviteCode = session.inviteCode;
        }
      }

      final report = _duoService.getWeeklyReport();
      emit(
        DuoLoaded(
          session: session,
          partner: partner,
          weeklyReport: report,
          inviteCode: inviteCode,
          isWaitingForPartner: isWaitingForPartner,
        ),
      );
    } catch (e) {
      emit(DuoError(e.toString()));
    }
  }

  Future<void> createDuoSession() async {
    emit(DuoLoading());
    try {
      await _duoService.createSession();
      await loadDuoData();
    } catch (e) {
      emit(DuoError(e.toString()));
    }
  }

  Future<void> joinDuoSession(String inviteCode) async {
    emit(DuoLoading());
    try {
      await _duoService.joinSession(inviteCode);
      await loadDuoData();
    } catch (e) {
      emit(DuoError(e.toString()));
    }
  }

  Future<void> sendPetal() async {
    final state = this.state;
    if (state is DuoLoaded && state.partner != null) {
      try {
        await _duoService.sendPetalEvent(state.partner!.id);
        debugPrint('Petal successfully sent to partner!');
      } catch (e) {
        debugPrint('DuoCubit: Error sending petal: $e');
      }
    }
  }
}
