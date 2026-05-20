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
import 'package:bloomie/features/task/presentation/screens/task_screen.dart';
import 'package:bloomie/features/journal/presentation/screens/journal_screen.dart';
import 'package:bloomie/features/shop/presentation/screens/shop_screen.dart';
import 'package:bloomie/features/shop/presentation/screens/wardrobe_screen.dart';
import 'package:bloomie/features/adventure/presentation/screens/adventure_screen.dart';
import 'package:bloomie/features/auth/presentation/screens/auth_screen.dart';
import 'package:bloomie/features/auth/cubit/auth_cubit.dart';
import 'package:bloomie/features/auth/cubit/auth_state.dart';
import 'package:bloomie/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  static final _shellNavigatorGardenKey = GlobalKey<NavigatorState>(debugLabel: 'garden');
  static final _shellNavigatorTasksKey = GlobalKey<NavigatorState>(debugLabel: 'tasks');
  static final _shellNavigatorDuoKey = GlobalKey<NavigatorState>(debugLabel: 'duo');
  static final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) {
      final authState = context.read<AuthCubit>().state;
      final isAuth = authState is AuthAuthenticated;
      final isSplashRoute = state.matchedLocation == '/splash';
      final isAuthRoute = state.matchedLocation == '/auth';
      final isOnboardingRoute = state.matchedLocation == '/onboarding';

      // Allow splash and onboarding screens to execute uninterrupted
      if (isSplashRoute || isOnboardingRoute) return null;

      if (!isAuth && !isAuthRoute) return '/auth';
      if (isAuth && (isAuthRoute || isOnboardingRoute)) return '/';
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),

      // Onboarding Screen
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),

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
          // Tasks Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorTasksKey,
            routes: [GoRoute(path: '/tasks', builder: (context, state) => const TaskScreen())],
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
      GoRoute(
        path: '/journal',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const JournalScreen(),
      ),
      GoRoute(
        path: '/shop',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ShopScreen(),
      ),
      GoRoute(
        path: '/wardrobe',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WardrobeScreen(),
      ),
      GoRoute(
        path: '/adventure',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdventureScreen(),
      ),
      GoRoute(
        path: '/auth',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuthScreen(),
      ),
    ],
  );
}
