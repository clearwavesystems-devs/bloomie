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
  final Plant activePlant;

  /// All plants the user has grown (personal garden collection).
  final List<Plant> allPlants;

  /// True when a stage upgrade just occurred — triggers celebration animation.
  final bool justLeveledUp;

  /// Blooms awarded in this session (for display in toast).
  final int bloomsJustAwarded;

  const GardenLoaded({
    required this.activePlant,
    required this.allPlants,
    this.justLeveledUp = false,
    this.bloomsJustAwarded = 0,
  });

  GardenLoaded copyWith({
    Plant? activePlant,
    List<Plant>? allPlants,
    bool? justLeveledUp,
    int? bloomsJustAwarded,
  }) {
    return GardenLoaded(
      activePlant: activePlant ?? this.activePlant,
      allPlants: allPlants ?? this.allPlants,
      justLeveledUp: justLeveledUp ?? this.justLeveledUp,
      bloomsJustAwarded: bloomsJustAwarded ?? this.bloomsJustAwarded,
    );
  }

  @override
  List<Object?> get props =>
      [activePlant, allPlants, justLeveledUp, bloomsJustAwarded];
}

class GardenError extends GardenState {
  final String message;

  const GardenError(this.message);

  @override
  List<Object?> get props => [message];
}
