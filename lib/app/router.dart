import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloomie/features/splash/presentation/screens/splash_screen.dart';
import 'package:bloomie/features/habits/presentation/screens/habit_screen.dart';
import 'package:bloomie/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bloomie/features/duo_mode/presentation/screens/duo_mode_screen.dart';
import 'package:bloomie/features/garden/presentation/screens/garden_screen.dart';
import 'package:bloomie/features/profile/presentation/screens/profile_screen.dart';
import 'package:bloomie/features/habits/presentation/screens/add_habit_screen.dart';
import 'package:bloomie/features/duo/presentation/screens/duo_screen.dart';

class AppRouter {
  static GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        // Check for maintenance mode
        // final maintenanceMode = FirebaseRemoteConfig.instance.getBool('maintenance_mode');
        // if (maintenanceMode && state.matchedLocation != '/maintenance') {
        //   return '/maintenance';
        // }

        // Check for force update
        // final forceUpdateVersion = FirebaseRemoteConfig.instance.getInt('force_update_version');
        // TODO: Compare with app version and uncomment below
        // if (appVersion < forceUpdateVersion && state.matchedLocation != '/force-update') {
        //   return '/force-update';
        // }

        // Splash is always allowed
        if (state.matchedLocation == '/splash' ||
            state.matchedLocation == '/maintenance' ||
            state.matchedLocation == '/force-update') {
          return null;
        }

        return null;
      },
      routes: [
        // Splash Screen
        GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),

        // Maintenance Screen
        GoRoute(
          path: '/maintenance',
          builder: (context, state) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build, size: 80.sp, color: Colors.orange),
                  SizedBox(height: 24.h),
                  Text('Under Maintenance', style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: 16.h),
                  const Text('We\'ll be back soon!'),
                ],
              ),
            ),
          ),
        ),

        // Force Update Screen
        GoRoute(
          path: '/force-update',
          builder: (context, state) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.system_update, size: 80.sp, color: Colors.blue),
                  SizedBox(height: 24.h),
                  Text('Update Required', style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: 16.h),
                  const Text('Please update to continue using the app.'),
                ],
              ),
            ),
          ),
        ),

        // Main App Navigation
        GoRoute(path: '/duo_mode', builder: (context, state) => const DuoModeScreen()),

        GoRoute(path: '/', builder: (context, state) => const HabitScreen()),

        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        GoRoute(path: '/garden', builder: (context, state) => const GardenScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        GoRoute(path: '/add-habit', builder: (context, state) => const AddHabitScreen()),
        GoRoute(path: '/duo', builder: (context, state) => const DuoScreen()),
      ],
    );
  }
}
