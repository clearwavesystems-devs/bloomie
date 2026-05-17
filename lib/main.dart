import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/database/app_database.dart';
import 'features/habits/cubit/habits_cubit.dart';
import 'features/habits/services/habit_service.dart';
import 'features/duo/cubit/duo_cubit.dart';
import 'features/duo/services/duo_service.dart';
import 'features/garden/cubit/garden_cubit.dart';
import 'features/garden/services/garden_service.dart';
import 'features/profile/cubit/profile_cubit.dart';
import 'features/task/cubit/task_cubit.dart';
import 'features/task/services/task_service.dart';
import 'features/journal/cubit/journal_cubit.dart';
import 'features/journal/services/journal_service.dart';
import 'features/shop/cubit/shop_cubit.dart';
import 'features/shop/services/shop_service.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/adventure/cubit/adventure_cubit.dart';
import 'package:bloomie/core/config/supabase_config.dart';
import 'app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  final database = AppDatabase();

  // Register Services
  final habitService = HabitService(database);
  final duoService = DuoService(database);
  final gardenService = GardenService(database);
  final taskService = TaskService(database);
  final journalService = JournalService(database);
  final shopService = ShopService(database);

  // Seed initial data if empty
  final existingHabits = await habitService.getAllHabits();
  if (existingHabits.isEmpty) {
    await habitService.saveHabit(
      Habit(
        id: 'stretch_id',
        name: 'Morning Stretch',
        emoji: '🧘',
        category: 1,
        frequency: 0,
        customDays: '[]',
        iconBg: 0xFFF2E8FF,
        isSharedWithPartner: true,
        currentCount: 0,
        targetCount: 1,
        streakCount: 0,
        longestStreak: 0,
        xpReward: 50,
        createdAt: DateTime.now(),
        isArchived: false,
      ),
    );
    await habitService.saveHabit(
      Habit(
        id: 'water_id',
        name: 'Drink 8 glasses',
        emoji: '💧',
        category: 0,
        frequency: 0,
        customDays: '[]',
        targetCount: 8,
        iconBg: 0xFFFDE8F0,
        isSharedWithPartner: true,
        currentCount: 0,
        streakCount: 0,
        longestStreak: 0,
        xpReward: 30,
        createdAt: DateTime.now(),
        isArchived: false,
      ),
    );

    // Seed Duo Session and Plant
    const sessionId = 'default_session';
    await database.insertSession(
      DuoSession(
        id: sessionId,
        userAId: 'user_1',
        userBId: 'user_2',
        sharedPlantId: 'plant_1',
        inviteCode: 'BLOOM123',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    );

    await database.insertPlant(
      Plant(
        id: 'plant_1',
        name: 'Eternal Rose',
        emoji: '🌹',
        stage: 1,
        growthPercent: 0.1,
        ownerId: 'shared',
        waterCount: 10,
        unlockedAt: DateTime.now(),
      ),
    );
  }

  runApp(
    BloomieApp(
      database: database,
      habitService: habitService,
      duoService: duoService,
      gardenService: gardenService,
      taskService: taskService,
      journalService: journalService,
      shopService: shopService,
    ),
  );
}

class BloomieApp extends StatelessWidget {
  final AppDatabase database;
  final HabitService habitService;
  final DuoService duoService;
  final GardenService gardenService;
  final TaskService taskService;
  final JournalService journalService;
  final ShopService shopService;

  const BloomieApp({
    super.key,
    required this.database,
    required this.habitService,
    required this.duoService,
    required this.gardenService,
    required this.taskService,
    required this.journalService,
    required this.shopService,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // ProfileCubit must be created first so it can be injected into
        // HabitsCubit and GardenCubit (single source of XP truth).
        final authService = AuthService();
        final profileCubit = ProfileCubit(authService);
        final authCubit = AuthCubit(authService, profileCubit);
        authCubit.checkSession(); // Restore session on startup

        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: profileCubit),
            BlocProvider.value(value: authCubit),
            BlocProvider(create: (_) => HabitsCubit(habitService, profileCubit)),
            BlocProvider(create: (_) => DuoCubit(duoService)),
            BlocProvider(create: (_) => GardenCubit(gardenService, profileCubit)),
            BlocProvider(create: (_) => TaskCubit(taskService, profileCubit)),
            BlocProvider(create: (_) => JournalCubit(journalService, profileCubit)),
            BlocProvider(create: (_) => ShopCubit(shopService, profileCubit, database)),
            BlocProvider(create: (_) => AdventureCubit(database, profileCubit)),
          ],
          child: MaterialApp.router(
            title: 'Bloomie',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}
