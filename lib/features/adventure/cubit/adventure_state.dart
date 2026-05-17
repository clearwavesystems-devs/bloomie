import 'package:equatable/equatable.dart';
import '../../../core/database/app_database.dart';

abstract class AdventureState extends Equatable {
  const AdventureState();

  @override
  List<Object?> get props => [];
}

class AdventureInitial extends AdventureState {}

class AdventureLoading extends AdventureState {}

class AdventureLoaded extends AdventureState {
  final List<AdventureLand> lands;
  final int currentLevel;

  const AdventureLoaded({
    required this.lands,
    required this.currentLevel,
  });

  @override
  List<Object?> get props => [lands, currentLevel];
}

class AdventureError extends AdventureState {
  final String message;

  const AdventureError(this.message);

  @override
  List<Object?> get props => [message];
}
