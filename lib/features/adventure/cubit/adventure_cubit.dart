import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/app_database.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';
import 'adventure_state.dart';
import '../models/adventure_content.dart';
import '../models/adventure_content_data.dart';

class AdventureCubit extends Cubit<AdventureState> {
  final AppDatabase _db;
  final ProfileCubit _profileCubit;
  final Random _random = Random();

  // Track discovered collectibles and unlocked lore (in-memory for session)
  Set<String> _discoveredCollectibles = {};
  Set<String> _unlockedLore = {};

  AdventureCubit(this._db, this._profileCubit) : super(AdventureInitial());

  // ── Load ───────────────────────────────────

  Future<void> loadLands() async {
    emit(AdventureLoading());
    try {
      final lands = await _db.getAllLands();
      final level = _getCurrentLevel();

      // Auto-unlock lands that meet the level requirement
      final updatedLands = <AdventureLand>[];
      for (final land in lands) {
        if (!land.unlocked && land.requiredLevel <= level) {
          final unlocked = land.copyWith(unlocked: true);
          await _db.updateLand(unlocked);
          updatedLands.add(unlocked);
        } else {
          updatedLands.add(land);
        }
      }

      emit(AdventureLoaded(
        lands: updatedLands,
        currentLevel: level,
        discoveredCollectibles: _discoveredCollectibles,
        unlockedLore: _unlockedLore,
      ));
    } catch (e) {
      emit(AdventureError(e.toString()));
    }
  }

  // ── Quick Explore (original simple method) ──────

  Future<void> exploreLand(AdventureLand land) async {
    if (state is! AdventureLoaded) return;
    if (!land.unlocked) return;

    // Progress increases by 10% per explore action, capped at 1.0
    final newProgress = (land.progress + 0.1).clamp(0.0, 1.0);
    final updated = land.copyWith(progress: newProgress);
    await _db.updateLand(updated);

    // Award XP for exploring
    await _profileCubit.addXP(30);

    await loadLands();
  }

  // ── Enhanced Gameplay Methods ─────────────────────────────────────

  /// Trigger a random event for the given land
  Future<void> triggerEvent(AdventureLand land) async {
    if (state is! AdventureLoaded) return;
    if (!land.unlocked) return;

    final events = AdventureContentData.getEventsForLand(land.id);
    if (events.isEmpty) {
      await exploreLand(land); // Fall back to simple explore
      return;
    }

    // Pick a random event
    final event = events[_random.nextInt(events.length)];
    emit(AdventureEventTriggered(event: event, currentLand: land));
  }

  /// Start a challenge for the given land
  Future<void> startChallenge(AdventureLand land) async {
    if (state is! AdventureLoaded) return;
    if (!land.unlocked) return;

    final challenges = AdventureContentData.getChallengesForLand(land.id);
    if (challenges.isEmpty) {
      await exploreLand(land); // Fall back to simple explore
      return;
    }

    // Pick a random challenge
    final challenge = challenges[_random.nextInt(challenges.length)];
    emit(AdventureChallengeActive(challenge: challenge, currentLand: land));
  }

  /// Handle player's choice in an event
  Future<void> makeEventChoice(EventChoice choice) async {
    if (state is! AdventureEventTriggered) return;

    final eventState = state as AdventureEventTriggered;
    final land = eventState.currentLand;

    // Calculate XP reward
    final xpEarned = choice.xpReward ?? eventState.event.baseXPReward ?? 15;

    // Apply progress bonus if any
    double newProgress = land.progress;
    if (choice.progressBonus != null) {
      newProgress = (land.progress + choice.progressBonus! / 100).clamp(0.0, 1.0);
      await _db.updateLand(land.copyWith(progress: newProgress));
    }

    // Award XP
    await _profileCubit.addXP(xpEarned);

    // Return to loaded state with updated lands
    final lands = await _db.getAllLands();
    emit(AdventureLoaded(
      lands: lands,
      currentLevel: _getCurrentLevel(),
      discoveredCollectibles: _discoveredCollectibles,
      unlockedLore: _unlockedLore,
    ));
  }

  /// Handle answer to a challenge
  Future<void> answerChallenge(ChallengeOption selectedOption) async {
    if (state is! AdventureChallengeActive) return;

    final challengeState = state as AdventureChallengeActive;
    final challenge = challengeState.challenge;
    final land = challengeState.currentLand;

    if (selectedOption.isCorrect) {
      // Correct answer!
      final xpEarned = challenge.xpReward;
      double newProgress = land.progress;

      if (challenge.progressBonus != null) {
        newProgress = (land.progress + challenge.progressBonus! / 100).clamp(0.0, 1.0);
        await _db.updateLand(land.copyWith(progress: newProgress));
      }

      await _profileCubit.addXP(xpEarned);

      final lands = await _db.getAllLands();
      emit(AdventureLoaded(
        lands: lands,
        currentLevel: _getCurrentLevel(),
        discoveredCollectibles: _discoveredCollectibles,
        unlockedLore: _unlockedLore,
      ));
    } else {
      // Wrong answer - still give small XP for trying
      await _profileCubit.addXP(5);

      // Return to loaded state
      final lands = await _db.getAllLands();
      emit(AdventureLoaded(
        lands: lands,
        currentLevel: _getCurrentLevel(),
        discoveredCollectibles: _discoveredCollectibles,
        unlockedLore: _unlockedLore,
      ));
    }
  }

  /// Try to find a collectible in the land (20% chance)
  Future<void> huntTreasure(AdventureLand land) async {
    if (state is! AdventureLoaded) return;
    if (!land.unlocked) return;

    // 20% chance to find something
    if (_random.nextDouble() > 0.2) {
      // No treasure found - do a normal explore
      await exploreLand(land);
      return;
    }

    final collectibles = AdventureContentData.getCollectiblesForLand(land.id);
    final undiscovered = collectibles.where((c) => !_discoveredCollectibles.contains(c.id)).toList();

    if (undiscovered.isEmpty) {
      // All collectibles already found - do normal explore
      await exploreLand(land);
      return;
    }

    // Find a random undiscovered collectible
    final found = undiscovered[_random.nextInt(undiscovered.length)];
    _discoveredCollectibles.add(found.id);

    // Award XP for finding collectible
    await _profileCubit.addXP(found.xpReward);

    emit(AdventureCollectibleFound(
      collectible: found,
      xpEarned: found.xpReward,
      currentLand: land,
    ));
  }

  /// Try to unlock lore based on current progress
  Future<void> discoverLore(AdventureLand land) async {
    if (state is! AdventureLoaded) return;

    final lore = AdventureContentData.getLoreForLand(land.id);
    final progressPercent = (land.progress * 100).toInt();

    // Find any lore that should be unlocked but hasn't been yet
    final newlyUnlocked = lore.entries.where((entry) {
      final loreId = '${land.id}_${entry.title}';
      return entry.requiredProgress <= progressPercent &&
             !_unlockedLore.contains(loreId);
    }).toList();

    if (newlyUnlocked.isEmpty) {
      // No new lore to unlock - do normal explore
      await exploreLand(land);
      return;
    }

    // Unlock the first newly discovered lore
    final loreEntry = newlyUnlocked.first;
    final loreId = '${land.id}_${loreEntry.title}';
    _unlockedLore.add(loreId);

    final lands = await _db.getAllLands();
    emit(AdventureLoreUnlocked(
      lore: loreEntry,
      landId: land.id,
      lands: lands,
      currentLevel: _getCurrentLevel(),
    ));
  }

  /// Return to the main loaded state
  void returnToLoaded() {
    if (state is! AdventureLoaded) {
      loadLands();
    }
  }

  // ── Helpers ────────────────────────────────

  int _getCurrentLevel() {
    final profileState = _profileCubit.state;
    if (profileState is ProfileLoaded) {
      return profileState.user.level;
    }
    return 1;
  }

  bool canUnlock(AdventureLand land) {
    return _getCurrentLevel() >= land.requiredLevel;
  }
}
