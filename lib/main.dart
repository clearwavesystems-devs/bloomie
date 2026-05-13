import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/database/app_database.dart';
import 'features/habits/cubit/habits_cubit.dart';
import 'features/habits/services/habit_service.dart';
import 'features/duo/cubit/duo_cubit.dart';
import 'features/duo/services/duo_service.dart';
import 'features/garden/cubit/garden_cubit.dart';
import 'features/garden/services/garden_service.dart';
import 'features/profile/cubit/profile_cubit.dart';
import 'app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final database = AppDatabase();
  
  // Register Services
  final habitService = HabitService(database);
  final duoService = DuoService(database);
  final gardenService = GardenService(database);
  
  // Seed initial data if empty
  final existingHabits = await habitService.getAllHabits();
  if (existingHabits.isEmpty) {
    await habitService.saveHabit(Habit(
      id: 'stretch_id',
      name: 'Morning Stretch',
      emoji: '🧘',
      category: 1, // wellness
      frequency: 0, // daily
      customDays: '[]',
      iconBg: 0xFFF2E8FF,
      isSharedWithPartner: true,
      currentCount: 0,
      targetCount: 1,
      streakCount: 0,
      longestStreak: 0,
      createdAt: DateTime.now(),
      isArchived: false,
    ));
    await habitService.saveHabit(Habit(
      id: 'water_id',
      name: 'Drink 8 glasses',
      emoji: '💧',
      category: 0, // hydration
      frequency: 0, // daily
      customDays: '[]',
      targetCount: 8,
      iconBg: 0xFFFDE8F0,
      isSharedWithPartner: true,
      currentCount: 0,
      streakCount: 0,
      longestStreak: 0,
      createdAt: DateTime.now(),
      isArchived: false,
    ));

    // Seed Duo Session and Plant
    const sessionId = 'default_session';
    await database.insertSession(DuoSession(
      id: sessionId,
      userAId: 'user_1',
      userBId: 'user_2',
      sharedPlantId: 'plant_1',
      inviteCode: 'BLOOM123',
      isActive: true,
      createdAt: DateTime.now(),
    ));

    await database.insertPlant(Plant(
      id: 'plant_1',
      name: 'Eternal Rose',
      emoji: '🌹',
      stage: 1,
      growthPercent: 0.1,
      duoSessionId: sessionId,
      waterCount: 10,
      unlockedAt: DateTime.now(),
    ));
  }

  runApp(BloomieApp(
    database: database,
    habitService: habitService,
    duoService: duoService,
    gardenService: gardenService,
  ));
}

class BloomieApp extends StatelessWidget {
  final AppDatabase database;
  final HabitService habitService;
  final DuoService duoService;
  final GardenService gardenService;

  const BloomieApp({
    super.key,
    required this.database,
    required this.habitService,
    required this.duoService,
    required this.gardenService,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => HabitsCubit(habitService)),
            BlocProvider(create: (context) => DuoCubit(duoService)),
            BlocProvider(create: (context) => GardenCubit(gardenService)),
            BlocProvider(create: (context) => ProfileCubit()),
          ],
          child: MaterialApp.router(
            title: 'Bloomie Duo Mode',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}
