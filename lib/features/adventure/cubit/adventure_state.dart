import 'package:equatable/equatable.dart';
import '../../../core/database/app_database.dart';
import '../models/adventure_content.dart';

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
  final Set<String> discoveredCollectibles;
  final Set<String> unlockedLore;

  const AdventureLoaded({
    required this.lands,
    required this.currentLevel,
    this.discoveredCollectibles = const {},
    this.unlockedLore = const {},
  });

  @override
  List<Object?> get props => [lands, currentLevel, discoveredCollectibles, unlockedLore];
}

class AdventureEventTriggered extends AdventureState {
  final AdventureEvent event;
  final AdventureLand currentLand;

  const AdventureEventTriggered({
    required this.event,
    required this.currentLand,
  });

  @override
  List<Object?> get props => [event, currentLand];
}

class AdventureChallengeActive extends AdventureState {
  final AdventureChallenge challenge;
  final AdventureLand currentLand;

  const AdventureChallengeActive({
    required this.challenge,
    required this.currentLand,
  });

  @override
  List<Object?> get props => [challenge, currentLand];
}

class AdventureCollectibleFound extends AdventureState {
  final Collectible collectible;
  final int xpEarned;
  final AdventureLand currentLand;

  const AdventureCollectibleFound({
    required this.collectible,
    required this.xpEarned,
    required this.currentLand,
  });

  @override
  List<Object?> get props => [collectible, xpEarned, currentLand];
}

class AdventureLoreUnlocked extends AdventureState {
  final LoreEntry lore;
  final String landId;
  final List<AdventureLand> lands;
  final int currentLevel;

  const AdventureLoreUnlocked({
    required this.lore,
    required this.landId,
    required this.lands,
    required this.currentLevel,
  });

  @override
  List<Object?> get props => [lore, landId, lands, currentLevel];
}

class AdventureExplorationResult extends AdventureState {
  final String title;
  final String message;
  final int xpEarned;
  final int? progressBonus;
  final List<AdventureLand> lands;
  final int currentLevel;

  const AdventureExplorationResult({
    required this.title,
    required this.message,
    required this.xpEarned,
    this.progressBonus,
    required this.lands,
    required this.currentLevel,
  });

  @override
  List<Object?> get props => [title, message, xpEarned, progressBonus, lands, currentLevel];
}

class AdventureError extends AdventureState {
  final String message;

  const AdventureError(this.message);

  @override
  List<Object?> get props => [message];
}
