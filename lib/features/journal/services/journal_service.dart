import '../../../core/database/app_database.dart';

class JournalService {
  final AppDatabase _db;

  JournalService(this._db);

  Future<JournalEntry?> getEntryForToday() => _db.getEntryForToday();

  Future<List<JournalEntry>> getAllJournalEntries() => _db.getAllJournalEntries();

  Future<void> saveJournalEntry(JournalEntry entry) async {
    await _db.insertJournalEntry(entry);
  }
}
