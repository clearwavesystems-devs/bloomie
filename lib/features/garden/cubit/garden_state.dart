import 'package:equatable/equatable.dart';
import '../../../core/database/app_database.dart';

abstract class GardenState extends Equatable {
  const GardenState();

  @override
  List<Object?> get props => [];
}

class GardenInitial extends GardenState {}

class GardenLoading extends GardenState {}

class GardenLoaded extends GardenState {
  final Plant currentPlant;
  final List<Plant> history;

  const GardenLoaded({
    required this.currentPlant,
    required this.history,
  });

  @override
  List<Object?> get props => [currentPlant, history];
}

class GardenError extends GardenState {
  final String message;

  const GardenError(this.message);

  @override
  List<Object?> get props => [message];
}
