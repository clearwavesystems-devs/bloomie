import '../models/adventure_content.dart';

/// Pre-built adventure content for all lands
class AdventureContentData {
  static List<AdventureEvent> getEventsForLand(String landId) {
    switch (landId) {
      case 'land_meadow':
        return _meadowEvents;
      case 'land_forest':
        return _forestEvents;
      case 'land_cave':
        return _caveEvents;
      case 'land_marsh':
        return _marshEvents;
      case 'land_sky':
        return _skyEvents;
      case 'land_cosmos':
        return _cosmosEvents;
      default:
        return [];
    }
  }

  static List<AdventureChallenge> getChallengesForLand(String landId) {
    switch (landId) {
      case 'land_meadow':
        return _meadowChallenges;
      case 'land_forest':
        return _forestChallenges;
      case 'land_cave':
        return _caveChallenges;
      case 'land_marsh':
        return _marshChallenges;
      case 'land_sky':
        return _skyChallenges;
      case 'land_cosmos':
        return _cosmosChallenges;
      default:
        return [];
    }
  }

  static List<Collectible> getCollectiblesForLand(String landId) {
    switch (landId) {
      case 'land_meadow':
        return _meadowCollectibles;
      case 'land_forest':
        return _forestCollectibles;
      case 'land_cave':
        return _caveCollectibles;
      case 'land_marsh':
        return _marshCollectibles;
      case 'land_sky':
        return _skyCollectibles;
      case 'land_cosmos':
        return _cosmosCollectibles;
      default:
        return [];
    }
  }

  static LandLore getLoreForLand(String landId) {
    switch (landId) {
      case 'land_meadow':
        return _meadowLore;
      case 'land_forest':
        return _forestLore;
      case 'land_cave':
        return _caveLore;
      case 'land_marsh':
        return _marshLore;
      case 'land_sky':
        return _skyLore;
      case 'land_cosmos':
        return _cosmosLore;
      default:
        return LandLore(landId: landId, entries: []);
    }
  }

  // ── MEADOW CONTENT ────────────────────────────────

  static final List<AdventureEvent> _meadowEvents = [
    AdventureEvent(
      id: 'meadow_event_butterfly',
      title: 'The Golden Butterfly',
      description: 'A beautiful golden butterfly lands on a flower nearby, seemingly waiting for something.',
      landId: 'land_meadow',
      type: EventType.randomEncounter,
      emoji: '🦋',
      choices: [
        EventChoice(
          text: 'Gently observe its beauty',
          resultText: 'The butterfly briefly touches your finger before fluttering away. You feel a sense of peace.',
          xpReward: 15,
          emoji: '🌸',
        ),
        EventChoice(
          text: 'Offer it some nectar',
          resultText: 'The butterfly gratefully accepts and leaves behind a sprinkle of golden dust.',
          xpReward: 20,
          progressBonus: 5,
          emoji: '✨',
        ),
        EventChoice(
          text: 'Try to catch it',
          resultText: 'The butterfly swiftly escapes, but you learned something about patience.',
          xpReward: 10,
          emoji: '💨',
        ),
      ],
    ),
    AdventureEvent(
      id: 'meadow_event_rain',
      title: 'Sudden Shower',
      description: 'A gentle rain begins to fall, nourishing the meadow. Flowers seem to bloom before your eyes.',
      landId: 'land_meadow',
      type: EventType.discovery,
      emoji: '🌧️',
      choices: [
        EventChoice(
          text: 'Dance in the rain',
          resultText: 'You twirl through the meadow, feeling alive and connected to nature.',
          xpReward: 20,
          emoji: '💃',
        ),
        EventChoice(
          text: 'Find shelter under a large leaf',
          resultText: 'You watch the rain peacefully, noticing tiny droplets creating prism effects.',
          xpReward: 15,
          emoji: '🌿',
        ),
      ],
    ),
  ];

  static final List<AdventureChallenge> _meadowChallenges = [
    AdventureChallenge(
      id: 'meadow_challenge_1',
      landId: 'land_meadow',
      question: 'What does a butterfly symbolize in many cultures?',
      type: ChallengeType.quiz,
      emoji: '🦋',
      xpReward: 25,
      progressBonus: 5,
      options: [
        ChallengeOption(text: 'Transformation', isCorrect: true, feedback: 'Correct! Butterflies symbolize transformation and growth.'),
        ChallengeOption(text: 'Strength', isCorrect: false, feedback: 'Not quite. Butterflies are more delicate symbols.'),
        ChallengeOption(text: 'War', isCorrect: false, feedback: 'Butterflies usually symbolize peace and change.'),
        ChallengeOption(text: 'Wisdom', isCorrect: false, feedback: 'Owls are more associated with wisdom.'),
      ],
    ),
    AdventureChallenge(
      id: 'meadow_challenge_2',
      landId: 'land_meadow',
      question: 'Riddle: I have no eyes, but I can see the wind. What am I?',
      type: ChallengeType.riddle,
      emoji: '🌾',
      xpReward: 30,
      progressBonus: 8,
      options: [
        ChallengeOption(text: 'A cloud', isCorrect: false, feedback: 'Clouds don\'t react to wind in that way.'),
        ChallengeOption(text: 'A tree', isCorrect: false, feedback: 'Trees have roots, not sight of wind.'),
        ChallengeOption(text: 'Grass or wheat', isCorrect: true, feedback: 'Correct! Grass waves in the wind, "seeing" it through movement.'),
        ChallengeOption(text: 'A bird', isCorrect: false, feedback: 'Birds have eyes and can see wind differently.'),
      ],
    ),
  ];

  static final List<Collectible> _meadowCollectibles = [
    Collectible(
      id: 'meadow_col_1',
      name: 'Golden Petal',
      description: 'A rare petal that shimmers like gold in sunlight.',
      emoji: '🌼',
      landId: 'land_meadow',
      rarity: 3,
      xpReward: 50,
    ),
    Collectible(
      id: 'meadow_col_2',
      name: 'Dewdrop Gem',
      description: 'A perfectly formed dewdrop that never evaporates.',
      emoji: '💎',
      landId: 'land_meadow',
      rarity: 4,
      xpReward: 75,
    ),
  ];

  static final LandLore _meadowLore = LandLore(
    landId: 'land_meadow',
    entries: [
      LoreEntry(
        title: 'The First Bloom',
        content: 'Legend says this meadow was born from a single flower that bloomed at the dawn of time. Its petals scattered to create all the flowers we see today.',
        requiredProgress: 20,
        emoji: '🌸',
      ),
      LoreEntry(
        title: 'The Butterfly Dance',
        content: 'Every spring, thousands of butterflies migrate here to perform their mating dance. It\'s said that witnessing it brings good fortune for a year.',
        requiredProgress: 50,
        emoji: '🦋',
      ),
      LoreEntry(
        title: 'The Secret of the Meadow',
        content: 'Beneath the peaceful surface lies an ancient magic. Those who truly listen can hear the flowers singing a lullaby that heals the soul.',
        requiredProgress: 80,
        emoji: '🎵',
      ),
    ],
  );

  // ── FOREST CONTENT ─────────────────────────────────

  static final List<AdventureEvent> _forestEvents = [
    AdventureEvent(
      id: 'forest_event_wolf',
      title: 'The Silent Watcher',
      description: 'You sense eyes watching you from between the trees. A majestic wolf appears, neither threatening nor friendly.',
      landId: 'land_forest',
      type: EventType.randomEncounter,
      emoji: '🐺',
      choices: [
        EventChoice(
          text: 'Bow respectfully to the guardian',
          resultText: 'The wolf nods back and shows you a hidden path filled with rare herbs.',
          xpReward: 25,
          progressBonus: 10,
          emoji: '🌿',
        ),
        EventChoice(
          text: 'Offer some food',
          resultText: 'The wolf accepts cautiously and seems less wary of you now.',
          xpReward: 15,
          emoji: '🍖',
        ),
        EventChoice(
          text: 'Slowly back away',
          resultText: 'The wolf watches you leave but doesn\'t follow. Safety first.',
          xpReward: 10,
          emoji: '🌲',
        ),
      ],
    ),
  ];

  static final List<AdventureChallenge> _forestChallenges = [
    AdventureChallenge(
      id: 'forest_challenge_1',
      landId: 'land_forest',
      question: 'Which tree is known as the "King of the Forest" in European folklore?',
      type: ChallengeType.quiz,
      emoji: '🌳',
      xpReward: 25,
      options: [
        ChallengeOption(text: 'Pine', isCorrect: false, feedback: 'Pine trees are common but not traditionally the king.'),
        ChallengeOption(text: 'Oak', isCorrect: true, feedback: 'Correct! The oak tree is often called the King of the Forest.'),
        ChallengeOption(text: 'Maple', isCorrect: false, feedback: 'Maple trees are beautiful but not the traditional king.'),
        ChallengeOption(text: 'Birch', isCorrect: false, feedback: 'Birch trees have their own significance but aren\'t the king.'),
      ],
    ),
  ];

  static final List<Collectible> _forestCollectibles = [
    Collectible(
      id: 'forest_col_1',
      name: 'Ancient Acorn',
      description: 'An acorn from the oldest tree in the forest.',
      emoji: '🌰',
      landId: 'land_forest',
      rarity: 4,
      xpReward: 75,
    ),
  ];

  static final LandLore _forestLore = LandLore(
    landId: 'land_forest',
    entries: [
      LoreEntry(
        title: 'The Ancient Roots',
        content: 'These trees have stood for millennia. Their roots intertwine deep underground, creating a network that connects all living things.',
        requiredProgress: 25,
        emoji: '🌳',
      ),
    ],
  );

  // ── CAVE CONTENT ───────────────────────────────────

  static final List<AdventureEvent> _caveEvents = [
    AdventureEvent(
      id: 'cave_event_crystal',
      title: 'The Singing Crystal',
      description: 'A large crystal resonates with a hauntingly beautiful melody when you approach.',
      landId: 'land_cave',
      type: EventType.discovery,
      emoji: '💎',
      choices: [
        EventChoice(
          text: 'Touch the crystal',
          resultText: 'Visions of ancient civilizations flood your mind. You feel wiser.',
          xpReward: 30,
          progressBonus: 5,
          emoji: '🔮',
        ),
        EventChoice(
          text: 'Listen quietly',
          resultText: 'The crystal\'s song calms your mind and restores your energy.',
          xpReward: 20,
          emoji: '🎵',
        ),
      ],
    ),
  ];

  static final List<AdventureChallenge> _caveChallenges = [
    AdventureChallenge(
      id: 'cave_challenge_1',
      landId: 'land_cave',
      question: 'Riddle: I have a bed but never sleep. I have a mouth but never speak. What am I?',
      type: ChallengeType.riddle,
      emoji: '🏔️',
      xpReward: 35,
      options: [
        ChallengeOption(text: 'A cave', isCorrect: true, feedback: 'Correct! Caves have "beds" (bottoms) and "mouths" (entrances).'),
        ChallengeOption(text: 'A river', isCorrect: false, feedback: 'Rivers flow and "speak" through sound.'),
        ChallengeOption(text: 'A statue', isCorrect: false, feedback: 'Statues don\'t have beds.'),
        ChallengeOption(text: 'A ghost', isCorrect: false, feedback: 'Ghosts "speak" in stories.'),
      ],
    ),
  ];

  static final List<Collectible> _caveCollectibles = [
    Collectible(
      id: 'cave_col_1',
      name: 'Moon Stone Shard',
      description: 'A fragment of crystal that glows in darkness.',
      emoji: '🌙',
      landId: 'land_cave',
      rarity: 4,
      xpReward: 80,
    ),
  ];

  static final LandLore _caveLore = LandLore(
    landId: 'land_cave',
    entries: [
      LoreEntry(
        title: 'The Echoes of Time',
        content: 'Deep within these caves, echoes of ancient conversations still resonate. Those with keen hearing can learn secrets lost to time.',
        requiredProgress: 30,
        emoji: '🗣️',
      ),
    ],
  );

  // ── MARSH CONTENT ───────────────────────────────────

  static final List<AdventureEvent> _marshEvents = [
    AdventureEvent(
      id: 'marsh_event_frog',
      title: 'The Wise Frog',
      description: 'A large frog sits on a lily pad, watching you with intelligent eyes.',
      landId: 'land_marsh',
      type: EventType.randomEncounter,
      emoji: '🐸',
      choices: [
        EventChoice(
          text: 'Ask for guidance',
          resultText: 'The frog speaks in riddles that somehow make perfect sense to your current situation.',
          xpReward: 25,
          emoji: '💭',
        ),
        EventChoice(
          text: 'Offer a compliment',
          resultText: 'The frog seems pleased and shows you the safest path through the marsh.',
          xpReward: 20,
          progressBonus: 5,
          emoji: '🛤️',
        ),
      ],
    ),
  ];

  static final List<AdventureChallenge> _marshChallenges = [
    AdventureChallenge(
      id: 'marsh_challenge_1',
      landId: 'land_marsh',
      question: 'What adaptation helps frogs survive in wetlands?',
      type: ChallengeType.quiz,
      emoji: '🐸',
      xpReward: 25,
      options: [
        ChallengeOption(text: 'Sharp claws', isCorrect: false, feedback: 'Frogs don\'t have claws.'),
        ChallengeOption(text: 'Permeable skin', isCorrect: true, feedback: 'Correct! Frogs can absorb oxygen through their skin.'),
        ChallengeOption(text: 'Thick fur', isCorrect: false, feedback: 'Frogs don\'t have fur.'),
        ChallengeOption(text: 'Gills', isCorrect: false, feedback: 'Adult frogs have lungs, not gills.'),
      ],
    ),
  ];

  static final List<Collectible> _marshCollectibles = [
    Collectible(
      id: 'marsh_col_1',
      name: 'Firefly Lantern',
      description: 'A captured firefly in a jar that never dims.',
      emoji: '🏮',
      landId: 'land_marsh',
      rarity: 3,
      xpReward: 60,
    ),
  ];

  static final LandLore _marshLore = LandLore(
    landId: 'land_marsh',
    entries: [
      LoreEntry(
        title: 'The Phantom Lights',
        content: 'Some say the fireflies here are the spirits of travelers who found their way. They guide the lost to safety.',
        requiredProgress: 40,
        emoji: '✨',
      ),
    ],
  );

  // ── SKY CONTENT ─────────────────────────────────────

  static final List<AdventureEvent> _skyEvents = [
    AdventureEvent(
      id: 'sky_event_cloud',
      title: 'The Cloud Weaver',
      description: 'A mythical creature weaves clouds into shapes, creating stories in the sky.',
      landId: 'land_sky',
      type: EventType.discovery,
      emoji: '☁️',
      choices: [
        EventChoice(
          text: 'Watch the stories unfold',
          resultText: 'You see tales of heroes and legends played out in cloud form. Inspiring!',
          xpReward: 25,
          emoji: '📖',
        ),
        EventChoice(
          text: 'Try to weave with them',
          resultText: 'The Cloud Weaver teaches you the ancient art of cloud shaping.',
          xpReward: 30,
          progressBonus: 8,
          emoji: '🎨',
        ),
      ],
    ),
  ];

  static final List<AdventureChallenge> _skyChallenges = [
    AdventureChallenge(
      id: 'sky_challenge_1',
      landId: 'land_sky',
      question: 'What type of cloud typically brings gentle rain?',
      type: ChallengeType.quiz,
      emoji: '🌧️',
      xpReward: 25,
      options: [
        ChallengeOption(text: 'Cumulonimbus', isCorrect: false, feedback: 'Those bring storms!'),
        ChallengeOption(text: 'Stratus', isCorrect: true, feedback: 'Correct! Stratus clouds bring steady, light rain.'),
        ChallengeOption(text: 'Cirrus', isCorrect: false, feedback: 'Cirrus clouds are high and wispy, no rain.'),
        ChallengeOption(text: 'Cumulus', isCorrect: false, feedback: 'Those are fair weather clouds.'),
      ],
    ),
  ];

  static final List<Collectible> _skyCollectibles = [
    Collectible(
      id: 'sky_col_1',
      name: 'Star Fragment',
      description: 'A piece of a fallen star that still twinkles.',
      emoji: '⭐',
      landId: 'land_sky',
      rarity: 5,
      xpReward: 100,
    ),
  ];

  static final LandLore _skyLore = LandLore(
    landId: 'land_sky',
    entries: [
      LoreEntry(
        title: 'The Wind Whispers',
        content: 'The winds here carry whispers from distant lands. Listen carefully, and you might hear messages from loved ones far away.',
        requiredProgress: 35,
        emoji: '🌬️',
      ),
    ],
  );

  // ── COSMOS CONTENT ───────────────────────────────────

  static final List<AdventureEvent> _cosmosEvents = [
    AdventureEvent(
      id: 'cosmos_event_nebula',
      title: 'The Living Nebula',
      description: 'A colorful nebula seems to pulse with life, reacting to your presence.',
      landId: 'land_cosmos',
      type: EventType.discovery,
      emoji: '🌌',
      choices: [
        EventChoice(
          text: 'Reach out to touch it',
          resultText: 'Your hand passes through, and you feel the birth of new stars. A cosmic experience!',
          xpReward: 35,
          progressBonus: 10,
          emoji: '✨',
        ),
        EventChoice(
          text: 'Observe from a respectful distance',
          resultText: 'The nebula shows you visions of the distant past and far future.',
          xpReward: 30,
          emoji: '👁️',
        ),
      ],
    ),
  ];

  static final List<AdventureChallenge> _cosmosChallenges = [
    AdventureChallenge(
      id: 'cosmos_challenge_1',
      landId: 'land_cosmos',
      question: 'What is a nebula?',
      type: ChallengeType.quiz,
      emoji: '🌌',
      xpReward: 30,
      options: [
        ChallengeOption(text: 'A black hole', isCorrect: false, feedback: 'Not quite - nebulas are different!'),
        ChallengeOption(text: 'A giant cloud of dust and gas', isCorrect: true, feedback: 'Correct! Nebulas are stellar nurseries.'),
        ChallengeOption(text: 'A type of star', isCorrect: false, feedback: 'Stars form inside nebulas.'),
        ChallengeOption(text: 'A galaxy', isCorrect: false, feedback: 'Galaxies are much larger than nebulas.'),
      ],
    ),
  ];

  static final List<Collectible> _cosmosCollectibles = [
    Collectible(
      id: 'cosmos_col_1',
      name: 'Cosmic Dust',
      description: 'Stardust from the beginning of the universe.',
      emoji: '✨',
      landId: 'land_cosmos',
      rarity: 5,
      xpReward: 120,
    ),
  ];

  static final LandLore _cosmosLore = LandLore(
    landId: 'land_cosmos',
    entries: [
      LoreEntry(
        title: 'The Origin',
        content: 'Here, at the edge of existence, you can see where it all began. The cosmos remembers everything that has ever happened.',
        requiredProgress: 50,
        emoji: '🌟',
      ),
    ],
  );
}
