import 'package:bloomie/app/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloomie/features/splash/presentation/screens/splash_screen.dart';
import 'package:bloomie/features/habits/presentation/screens/habit_screen.dart';
import 'package:bloomie/features/settings/presentation/screens/settings_screen.dart';
import 'package:bloomie/features/garden/presentation/screens/garden_screen.dart';
import 'package:bloomie/features/profile/presentation/screens/profile_screen.dart';
import 'package:bloomie/features/habits/presentation/screens/add_habit_screen.dart';
import 'package:bloomie/features/duo/presentation/screens/duo_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  static final _shellNavigatorGardenKey = GlobalKey<NavigatorState>(debugLabel: 'garden');
  static final _shellNavigatorDuoKey = GlobalKey<NavigatorState>(debugLabel: 'duo');
  static final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    routes: [
      // Splash Screen
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),

      // Main App Navigation with Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Home (Habits) Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [GoRoute(path: '/', builder: (context, state) => const HabitScreen())],
          ),
          // Garden Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorGardenKey,
            routes: [GoRoute(path: '/garden', builder: (context, state) => const GardenScreen())],
          ),
          // Duo Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDuoKey,
            routes: [GoRoute(path: '/duo', builder: (context, state) => const DuoScreen())],
          ),
          // Profile Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())],
          ),
        ],
      ),

      // Routes outside the shell
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/add-habit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddHabitScreen(),
      ),
    ],
  );
}
