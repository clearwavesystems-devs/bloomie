import 'package:equatable/equatable.dart';
import '../../../core/database/app_database.dart';

abstract class JournalState extends Equatable {
  const JournalState();

  @override
  List<Object?> get props => [];
}

class JournalInitial extends JournalState {}

class JournalLoading extends JournalState {}

class JournalLoaded extends JournalState {
  final JournalEntry? todayEntry;
  final List<JournalEntry> history;
  final String? selectedMood;
  final int selectedScore;

  const JournalLoaded({
    this.todayEntry,
    required this.history,
    this.selectedMood,
    this.selectedScore = 3,
  });

  JournalLoaded copyWith({
    JournalEntry? Function()? todayEntry,
    List<JournalEntry>? history,
    String? Function()? selectedMood,
    int? selectedScore,
  }) {
    return JournalLoaded(
      todayEntry: todayEntry != null ? todayEntry() : this.todayEntry,
      history: history ?? this.history,
      selectedMood: selectedMood != null ? selectedMood() : this.selectedMood,
      selectedScore: selectedScore ?? this.selectedScore,
    );
  }

  @override
  List<Object?> get props => [todayEntry, history, selectedMood, selectedScore];
}

class JournalError extends JournalState {
  final String message;

  const JournalError(this.message);

  @override
  List<Object?> get props => [message];
}
