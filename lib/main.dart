import 'package:bloomie/features/auth/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'core/theme/app_theme.dart';
import 'core/database/app_database.dart';
import 'core/sync/data_sync_service.dart';
import 'core/sync/sync_queue_service.dart';
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
  Provider.debugCheckInvalidValueType = null;

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  final database = AppDatabase();

  // Register Sync Queue
  final syncQueueService = SyncQueueService();
  await syncQueueService.loadQueueFromStorage();
  syncQueueService.startNetworkMonitoring();

  // Register Services
  final habitService = HabitService(database, syncQueueService);
  final duoService = DuoService(database);
  final gardenService = GardenService(database);
  final taskService = TaskService(database, syncQueueService);
  final journalService = JournalService(database, syncQueueService);
  final shopService = ShopService(database);

  runApp(
    BloomieApp(
      database: database,
      syncQueueService: syncQueueService,
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
  final SyncQueueService syncQueueService;
  final HabitService habitService;
  final DuoService duoService;
  final GardenService gardenService;
  final TaskService taskService;
  final JournalService journalService;
  final ShopService shopService;
  late final DataSyncService dataSyncService;

  BloomieApp({
    super.key,
    required this.database,
    required this.syncQueueService,
    required this.habitService,
    required this.duoService,
    required this.gardenService,
    required this.taskService,
    required this.journalService,
    required this.shopService,
  }) {
    dataSyncService = DataSyncService(
      habitService: habitService,
      taskService: taskService,
      journalService: journalService,
    );
  }

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

        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: database),
            RepositoryProvider.value(value: syncQueueService),
            RepositoryProvider.value(value: dataSyncService),
            RepositoryProvider.value(value: habitService),
            RepositoryProvider.value(value: taskService),
            RepositoryProvider.value(value: journalService),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: profileCubit),
              BlocProvider.value(value: authCubit),
              BlocProvider(
                create: (_) => HabitsCubit(habitService, profileCubit),
              ),
              BlocProvider(create: (_) => DuoCubit(duoService)),
              BlocProvider(
                create: (_) => GardenCubit(gardenService, profileCubit),
              ),
              BlocProvider(create: (_) => TaskCubit(taskService, profileCubit)),
              BlocProvider(
                create: (_) => JournalCubit(journalService, profileCubit),
              ),
              BlocProvider(
                create: (_) => ShopCubit(shopService, profileCubit, database),
              ),
              BlocProvider(
                create: (_) => AdventureCubit(database, profileCubit),
              ),
            ],
            child: BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  // Sync data from Supabase when user logs in or session is restored
                  dataSyncService.syncInBackground();
                } else if (state is AuthUnauthenticated) {
                  final routeState =
                      AppRouter.router.routerDelegate.currentConfiguration;
                  final location = routeState.uri.path;
                  if (location != '/splash') {
                    AppRouter.router.go('/auth');
                  }
                }
              },
              child: MaterialApp.router(
                title: 'Bloomie',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                routerConfig: AppRouter.router,
              ),
            ),
          ),
        );
      },
    );
  }
}
