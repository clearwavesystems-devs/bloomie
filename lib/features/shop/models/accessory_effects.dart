/// Special abilities and effects for shop accessories
/// Makes accessories more than just cosmetic!

class AccessoryEffect {
  final String id;
  final String name;
  final String description;
  final AccessoryType type;
  final double? value; // Effect strength
  final String? icon;

  const AccessoryEffect({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.value,
    this.icon,
  });
}

enum AccessoryType {
  xpBoost,          // Bonus XP from activities
  bloomBoost,       // Bonus Blooms from activities
  streakProtection, // Protect streak from breaking
  moodBoost,        // Always happy mood
  gardenGrowth,     // Faster garden growth
  duoBonus,         // Extra duo rewards
  hintAbility,      // See hints in challenges
  masteryBonus,     // Level up accessories faster
  spookyCharm,      // Halloween exclusive effects
  festiveCheer,      // Winter exclusive effects
}

// ── Accessory Effect Definitions ─────────────────────────────────────

class AccessoryEffects {
  static const Map<String, List<AccessoryEffect>> effects = {
    'acc_bow': [
      AccessoryEffect(
        id: 'bow_duo',
        name: 'Charm Bonus',
        description: '+25% more duo petals when sending to partner',
        type: AccessoryType.duoBonus,
        value: 0.25,
        icon: '🌸',
      ),
    ],
    'acc_crown': [
      AccessoryEffect(
        id: 'crown_bloom',
        name: 'Royal Harvest',
        description: '+50% Blooms from all activities',
        type: AccessoryType.bloomBoost,
        value: 0.5,
        icon: '👑',
      ),
    ],
    'acc_hat': [
      AccessoryEffect(
        id: 'hat_protection',
        name: 'Streak Guard',
        description: 'Protects your streak once per week if you miss habits',
        type: AccessoryType.streakProtection,
        value: 1.0,
        icon: '🛡️',
      ),
    ],
    'acc_scarf': [
      AccessoryEffect(
        id: 'scarf_mood',
        name: 'Cozy Comfort',
        description: 'Your pet is always in happy mood',
        type: AccessoryType.moodBoost,
        value: 1.0,
        icon: '😊',
      ),
    ],
    'acc_glasses': [
      AccessoryEffect(
        id: 'glasses_wisdom',
        name: 'Wisdom Vision',
        description: 'See hints in adventure challenges (10% chance)',
        type: AccessoryType.hintAbility,
        value: 0.1,
        icon: '👓',
      ),
    ],
    'acc_wings': [
      AccessoryEffect(
        id: 'wings_xp',
        name: 'Flight Bonus',
        description: '+15% XP from all activities',
        type: AccessoryType.xpBoost,
        value: 0.15,
        icon: '✨',
      ),
    ],
    'acc_ribbon': [
      AccessoryEffect(
        id: 'ribbon_garden',
        name: 'Growth Accelerator',
        description: '+20% faster garden plant growth',
        type: AccessoryType.gardenGrowth,
        value: 0.2,
        icon: '🌱',
      ),
    ],
    // 🎃 HALLOWEEN ACCESSORIES
    'acc_pumpkin_hat': [
      AccessoryEffect(
        id: 'pumpkin_spooky',
        name: 'Spooky Charm',
        description: '+10% XP during Halloween season',
        type: AccessoryType.xpBoost,
        value: 0.1,
        icon: '🎃',
      ),
    ],
    'acc_ghost_ears': [
      AccessoryEffect(
        id: 'ghost_phases',
        name: 'Ethereal Form',
        description: 'Phase through obstacles (no habit streak loss on first miss)',
        type: AccessoryType.streakProtection,
        value: 1.0,
        icon: '👻',
      ),
    ],
    'acc_witch_hat': [
      AccessoryEffect(
        id: 'witch_magic',
        name: 'Witch\'s Brew',
        description: '+25% Blooms during spooky season',
        type: AccessoryType.bloomBoost,
        value: 0.25,
        icon: '🧙‍♀️',
      ),
    ],
    'acc_bat_wings': [
      AccessoryEffect(
        id: 'bat_flight',
        name: 'Night Flight',
        description: '+20% XP during nighttime hours (6PM - 6AM)',
        type: AccessoryType.xpBoost,
        value: 0.2,
        icon: '🦇',
      ),
    ],
    'acc_spider_kitten': [
      AccessoryEffect(
        id: 'spider_web',
        name: 'Web Network',
        description: '+15% duo connection strength',
        type: AccessoryType.duoBonus,
        value: 0.15,
        icon: '🕷️',
      ),
    ],
    // ❄️ WINTER ACCESSORIES
    'acc_santa_hat': [
      AccessoryEffect(
        id: 'santa_gift',
        name: 'Santa\'s Gift',
        description: '+30% Blooms during December',
        type: AccessoryType.bloomBoost,
        value: 0.3,
        icon: '🎅',
      ),
    ],
    'acc_earmuffs': [
      AccessoryEffect(
        id: 'earmuffs_warm',
        name: 'Winter Warmth',
        description: 'Prevents mood drops in cold weather',
        type: AccessoryType.moodBoost,
        value: 1.0,
        icon: '🧣',
      ),
    ],
    'acc_snowflakes': [
      AccessoryEffect(
        id: 'snowflake_chill',
        name: 'Frozen Focus',
        description: '+20% XP for focus tasks completed',
        type: AccessoryType.xpBoost,
        value: 0.2,
        icon: '❄️',
      ),
    ],
    'acc_reindeer_antlers': [
      AccessoryEffect(
        id: 'reindeer_spirit',
        name: 'Holiday Spirit',
        description: '+25% all rewards during holiday season',
        type: AccessoryType.xpBoost,
        value: 0.25,
        icon: '🦌',
      ),
    ],
    'acc_candy_basket': [
      AccessoryEffect(
        id: 'candy_basket_effect',
        name: 'Sweet Treat',
        description: '+10% Blooms from all activities',
        type: AccessoryType.bloomBoost,
        value: 0.1,
        icon: '🍬',
      ),
    ],
    'acc_vampire_cape': [
      AccessoryEffect(
        id: 'vampire_cape_effect',
        name: 'Vampiric Vitality',
        description: '+15% XP during nighttime hours (6PM - 6AM)',
        type: AccessoryType.xpBoost,
        value: 0.15,
        icon: '🧛',
      ),
    ],
    'acc_franken_bolts': [
      AccessoryEffect(
        id: 'franken_bolts_effect',
        name: 'Electrifying Focus',
        description: '+10% XP for focus tasks completed',
        type: AccessoryType.xpBoost,
        value: 0.1,
        icon: '🔩',
      ),
    ],
    'acc_snowman_scarf': [
      AccessoryEffect(
        id: 'snowman_scarf_effect',
        name: 'Snowman Hug',
        description: 'Your pet is always in happy mood',
        type: AccessoryType.moodBoost,
        value: 1.0,
        icon: '☃️',
      ),
    ],
    'acc_elf_ears': [
      AccessoryEffect(
        id: 'elf_ears_effect',
        name: 'Elf Helper',
        description: '+15% more duo rewards in Duo Mode',
        type: AccessoryType.duoBonus,
        value: 0.15,
        icon: '🧝',
      ),
    ],
    'acc_ice_crown': [
      AccessoryEffect(
        id: 'ice_crown_effect',
        name: 'Glacial Harvest',
        description: '+40% Blooms during December',
        type: AccessoryType.bloomBoost,
        value: 0.4,
        icon: '❄️',
      ),
    ],
  };

  /// Get effects for a specific accessory
  static List<AccessoryEffect> getEffects(String accessoryId) {
    return effects[accessoryId] ?? [];
  }

  /// Get all equipped effects for current accessories
  static List<AccessoryEffect> getEquippedEffects(List<String> equippedAccessoryIds) {
    final allEffects = <AccessoryEffect>[];
    for (final id in equippedAccessoryIds) {
      allEffects.addAll(getEffects(id));
    }
    return allEffects;
  }

  /// Calculate XP multiplier from equipped accessories
  static double calculateXPMultiplier(
    List<String> equippedAccessories, {
    bool isFocusTask = false,
    bool isDuoActive = false,
  }) {
    double multiplier = 1.0;
    final now = DateTime.now();
    final hour = now.hour;
    final month = now.month;
    final day = now.day;

    final isHalloween = month == 10 && day >= 15 && day <= 31;
    final isHolidaySeason = (month == 12 && day >= 20) || (month == 1 && day <= 7);
    final isNight = hour >= 18 || hour < 6;

    for (final effect in getEquippedEffects(equippedAccessories)) {
      if (effect.type == AccessoryType.xpBoost) {
        if (effect.id == 'pumpkin_spooky' && !isHalloween) continue;
        if (effect.id == 'bat_flight' && !isNight) continue;
        if (effect.id == 'vampire_cape_effect' && !isNight) continue;
        if (effect.id == 'snowflake_chill' && !isFocusTask) continue;
        if (effect.id == 'franken_bolts_effect' && !isFocusTask) continue;
        if (effect.id == 'reindeer_spirit' && !isHolidaySeason) continue;

        multiplier += effect.value ?? 0;
      } else if (effect.type == AccessoryType.duoBonus && isDuoActive) {
        multiplier += effect.value ?? 0;
      }
    }
    return multiplier;
  }

  /// Calculate Bloom multiplier from equipped accessories
  static double calculateBloomMultiplier(
    List<String> equippedAccessories, {
    bool isDuoActive = false,
  }) {
    double multiplier = 1.0;
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;

    final isHalloween = month == 10 && day >= 15 && day <= 31;
    final isDecember = month == 12;
    final isHolidaySeason = (month == 12 && day >= 20) || (month == 1 && day <= 7);

    for (final effect in getEquippedEffects(equippedAccessories)) {
      if (effect.type == AccessoryType.bloomBoost) {
        if (effect.id == 'witch_magic' && !isHalloween) continue;
        if (effect.id == 'santa_gift' && !isDecember) continue;
        if (effect.id == 'ice_crown_effect' && !isDecember) continue;

        multiplier += effect.value ?? 0;
      } else if (effect.type == AccessoryType.duoBonus && isDuoActive) {
        multiplier += effect.value ?? 0;
      } else if (effect.type == AccessoryType.xpBoost && effect.id == 'reindeer_spirit' && isHolidaySeason) {
        // Reindeer antlers also boost Blooms during holiday season
        multiplier += effect.value ?? 0;
      }
    }
    return multiplier;
  }

  /// Check if streak protection is active
  static bool hasStreakProtection(List<String> equippedAccessories) {
    return getEquippedEffects(equippedAccessories)
        .any((e) => e.type == AccessoryType.streakProtection);
  }

  /// Check if mood boost is active
  static bool hasMoodBoost(List<String> equippedAccessories) {
    return getEquippedEffects(equippedAccessories)
        .any((e) => e.type == AccessoryType.moodBoost);
  }

  /// Get garden growth bonus
  static double getGardenGrowthBonus(List<String> equippedAccessories) {
    double bonus = 0.0;
    for (final effect in getEquippedEffects(equippedAccessories)) {
      if (effect.type == AccessoryType.gardenGrowth) {
        bonus += effect.value ?? 0;
      }
    }
    return bonus;
  }

  /// Check if seasonal effects are active
  static bool hasSeasonalEffect(List<String> equippedAccessories) {
    return getEquippedEffects(equippedAccessories)
        .any((e) => e.type == AccessoryType.spookyCharm || e.type == AccessoryType.festiveCheer);
  }

  /// Get seasonal bonus multiplier (time-based)
  static double getSeasonalBonus() {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;

    // Halloween: October 15-31
    if (month == 10 && day >= 15 && day <= 31) {
      return 1.2; // +20% all rewards
    }
    // Christmas: December 20-31
    if (month == 12 && day >= 20 && day <= 31) {
      return 1.25; // +25% all rewards
    }
    // New Year: January 1-7
    if (month == 1 && day <= 7) {
      return 1.15; // +15% all rewards
    }
    return 1.0;
  }
}
