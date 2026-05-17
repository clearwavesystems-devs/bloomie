import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../services/journal_service.dart';
import 'journal_state.dart';

class JournalCubit extends Cubit<JournalState> {
  final JournalService _journalService;
  final ProfileCubit _profileCubit;

  JournalCubit(this._journalService, this._profileCubit) : super(JournalInitial());

  // ── Load ───────────────────────────────────

  Future<void> loadJournal() async {
    emit(JournalLoading());
    try {
      final today = await _journalService.getEntryForToday();
      final history = await _journalService.getAllJournalEntries();
      
      emit(JournalLoaded(
        todayEntry: today,
        history: history,
        selectedMood: today?.mood,
        selectedScore: today?.moodScore ?? 3,
      ));
    } catch (e) {
      emit(JournalError(e.toString()));
    }
  }

  // ── Select Mood ────────────────────────────

  void selectMood(String mood, int score) {
    if (state is! JournalLoaded) return;
    final current = state as JournalLoaded;
    
    emit(current.copyWith(
      selectedMood: () => mood,
      selectedScore: score,
    ));
  }

  // ── Write Entry ────────────────────────────

  Future<bool> completeJournalEntry(String content) async {
    if (state is! JournalLoaded) return false;
    final current = state as JournalLoaded;

    if (current.todayEntry != null) return false; // Already written today
    if (current.selectedMood == null) return false; // Mood must be selected

    try {
      final entry = JournalEntry(
        id: const Uuid().v4(),
        content: content.trim(),
        mood: current.selectedMood!,
        moodScore: current.selectedScore,
        createdAt: DateTime.now(),
      );

      await _journalService.saveJournalEntry(entry);

      // Award XP and Blooms rewards
      await _profileCubit.addXP(100);
      await _profileCubit.addBlooms(15);

      await loadJournal();
      return true;
    } catch (e) {
      emit(JournalError(e.toString()));
      return false;
    }
  }
}
