/// Exploration types for variety in gameplay
enum ExplorationType {
  quickExplore,
  challenge,
  treasureHunt,
  loreDiscovery,
}

/// Adventure events that occur during exploration
class AdventureEvent {
  final String id;
  final String title;
  final String description;
  final String landId; // Which land this event belongs to
  final EventType type;
  final List<EventChoice> choices;
  final int? baseXPReward;
  final String? emoji;

  AdventureEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.landId,
    required this.type,
    required this.choices,
    this.baseXPReward = 15,
    this.emoji,
  });
}

enum EventType {
  randomEncounter,
  discovery,
  challenge,
  storyBeat,
}

class EventChoice {
  final String text;
  final String? resultText;
  final int? xpReward;
  final int? progressBonus;
  final String? emoji;

  EventChoice({
    required this.text,
    this.resultText,
    this.xpReward,
    this.progressBonus,
    this.emoji,
  });
}

/// Collectible items found in lands
class Collectible {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final String landId;
  final int rarity; // 1-5, 5 being legendary
  final int xpReward;

  Collectible({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.landId,
    required this.rarity,
    required this.xpReward,
  });
}

/// Challenge questions/tasks for lands
class AdventureChallenge {
  final String id;
  final String landId;
  final String question;
  final List<ChallengeOption> options;
  final int xpReward;
  final int? progressBonus;
  final ChallengeType type;
  final String? emoji;

  AdventureChallenge({
    required this.id,
    required this.landId,
    required this.question,
    required this.options,
    required this.xpReward,
    this.progressBonus,
    required this.type,
    this.emoji,
  });
}

enum ChallengeType {
  quiz,
  riddle,
  wisdom,
  observation,
}

class ChallengeOption {
  final String text;
  final bool isCorrect;
  final String? feedback;

  ChallengeOption({
    required this.text,
    required this.isCorrect,
    this.feedback,
  });
}

/// Land-specific lore and narrative content
class LandLore {
  final String landId;
  final List<LoreEntry> entries;

  LandLore({
    required this.landId,
    required this.entries,
  });
}

class LoreEntry {
  final String title;
  final String content;
  final int requiredProgress; // Minimum % progress needed to unlock
  final String? emoji;

  LoreEntry({
    required this.title,
    required this.content,
    required this.requiredProgress,
    this.emoji,
  });
}
