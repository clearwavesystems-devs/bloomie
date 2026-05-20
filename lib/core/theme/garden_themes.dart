import 'package:flutter/material.dart';

/// Garden theme definitions for plant skins
class GardenTheme {
  final String id;          // Unique identifier
  final String name;        // Display name
  final String description;  // Theme description
  final Color backgroundColor; // Main background color
  final Color cardColor;     // Card/plant container color
  final Color accentColor;   // Accent color for UI elements
  final Color primaryText;   // Primary text color
  final Color secondaryText; // Secondary/muted text color
  final List<Color> gradientColors; // Optional gradient colors
  final bool hasPattern;     // Whether to apply pattern
  final String? patternEmoji; // Pattern element if applicable

  const GardenTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.backgroundColor,
    required this.cardColor,
    required this.accentColor,
    required this.primaryText,
    required this.secondaryText,
    this.gradientColors = const [],
    this.hasPattern = false,
    this.patternEmoji,
  });
}

/// Collection of available garden themes
class GardenThemes {
  /// Default theme (normal garden)
  static const GardenTheme defaultTheme = GardenTheme(
    id: 'default',
    name: 'Sunny Meadow',
    description: 'Bright and cheerful garden',
    backgroundColor: Color(0xFFFFF8F9), // Cream background
    cardColor: Colors.white,
    accentColor: Color(0xFFE896B0), // Primary pink
    primaryText: Color(0xFF3A2030), // Dark text
    secondaryText: Color(0xFFBBA8B0), // Muted text
    hasPattern: false,
  );

  /// Golden rose theme
  static const GardenTheme goldenRoseTheme = GardenTheme(
    id: 'golden_rose',
    name: 'Golden Rose Garden',
    description: 'Luxurious golden atmosphere',
    backgroundColor: Color(0xFFFFF8E1), // Golden cream
    cardColor: Color(0xFFFFECB3), // Light golden yellow
    accentColor: Color(0xFFDAA520), // Golden accent
    primaryText: Color(0xFF8B4513), // Dark brown
    secondaryText: Color(0xFFCD853F), // Peru brown
    gradientColors: [
      Color(0xFFFFF8E1),
      Color(0xFFFFE5B4),
    ],
    hasPattern: true,
    patternEmoji: '🌹', // Rose pattern
  );

  /// Crystal bloom theme
  static const GardenTheme crystalBloomTheme = GardenTheme(
    id: 'crystal_bloom',
    name: 'Crystal Bloom Garden',
    description: 'Magical crystal-clear atmosphere',
    backgroundColor: Color(0xFFE6F3FF), // Light blue
    cardColor: Color(0xFFE0F2FE), // Light cyan
    accentColor: Color(0xFF40E0D0), // Turquoise
    primaryText: Color(0xFF003F5C), // Dark blue
    secondaryText: Color(0xFF58508D), // Blue purple
    gradientColors: [
      Color(0xFFE6F3FF),
      Color(0xFFD1E9FF),
    ],
    hasPattern: true,
    patternEmoji: '💎', // Crystal pattern
  );

  /// Rainbow flower theme
  static const GardenTheme rainbowFlowerTheme = GardenTheme(
    id: 'rainbow_flower',
    name: 'Rainbow Flower Garden',
    description: 'Vibrant rainbow paradise',
    backgroundColor: Color(0xFFFFE6F7), // Light pink
    cardColor: Color(0xFFFCE4EC), // Light pink card
    accentColor: Color(0xFFE91E63), // Hot pink
    primaryText: Color(0xFF880E4F), // Dark pink
    secondaryText: Color(0xFFFF6E40), // Orange
    gradientColors: [
      Color(0xFFFFE6F7),
      Color(0xFFFFE0EC),
      Color(0xFFFFDBF0),
    ],
    hasPattern: true,
    patternEmoji: '🌸', // Flower pattern
  );

  /// Cherry blossom theme
  static const GardenTheme cherryBlossomTheme = GardenTheme(
    id: 'cherry_blossom',
    name: 'Cherry Blossom Garden',
    description: 'Delicate pink sakura garden',
    backgroundColor: Color(0xFFFFE5EC), // Light pink
    cardColor: Color(0xFFFFF0F5), // Lavender blush
    accentColor: Color(0xFFFFB6C1), // Light pink
    primaryText: Color(0xFF8B008B), // Dark magenta
    secondaryText: Color(0xFFDDA0DD), // Plum
    gradientColors: [
      Color(0xFFFFE5EC),
      Color(0xFFFFD0DC),
    ],
    hasPattern: true,
    patternEmoji: '🌸', // Sakura pattern
  );

  /// Get all available themes
  static List<GardenTheme> get allThemes => [
    defaultTheme,
    goldenRoseTheme,
    crystalBloomTheme,
    rainbowFlowerTheme,
    cherryBlossomTheme,
  ];

  /// Get theme by ID
  static GardenTheme? byId(String id) {
    return allThemes.firstWhere(
      (theme) => theme.id == id,
      orElse: () => defaultTheme,
    );
  }

  /// Get theme for a plant skin (maps ShopItem.id to theme)
  static GardenTheme forPlantSkin(String skinId) {
    switch (skinId) {
      case 'plant_skin_golden_rose':
        return goldenRoseTheme;
      case 'plant_skin_crystal_bloom':
        return crystalBloomTheme;
      case 'plant_skin_rainbow_flower':
        return rainbowFlowerTheme;
      case 'plant_skin_cherry_blossom':
        return cherryBlossomTheme;
      default:
        return defaultTheme;
    }
  }
}