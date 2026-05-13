import '../../../core/database/app_database.dart';
import '../models/partner_model.dart';
import 'partner_simulator.dart';

class DuoService {
  final AppDatabase _db;

  DuoService(this._db);

  Future<DuoSession?> getActiveSession() => _db.getActiveSession();

  Future<void> saveSession(DuoSession session) async {
    await _db.insertSession(session);
  }

  PartnerModel getPartnerStatus() {
    return PartnerSimulator.generateMockPartner();
  }

  Map<String, List<double>> getWeeklyReport() {
    return PartnerSimulator.generateWeeklyReport();
  }
}
