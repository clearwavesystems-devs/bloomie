import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bloomie/app/router.dart';
import 'package:bloomie/core/theme/app_theme.dart';
import 'package:bloomie/core/theme/cubit/theme_cubit.dart';
import 'package:bloomie/core/locale/cubit/locale_cubit.dart';
import 'package:bloomie/cubits/network_cubit.dart';
import 'package:bloomie/core/services/network_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSkeleton extends StatefulWidget {
  const AppSkeleton({super.key});

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton> with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _router = AppRouter.router;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Trigger sync when app resumes
      context.read<NetworkCubit>().checkConnection();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
            BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
            BlocProvider<NetworkCubit>(create: (_) => NetworkCubit(NetworkService())),
          ],
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              final isDark =
                  themeState.themeMode == ThemeMode.dark ||
                  (themeState.themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) == Brightness.dark);

              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                  systemNavigationBarColor: isDark
                      ? AppTheme.dark.colorScheme.surface
                      : AppTheme.light.colorScheme.surface,
                  systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                ),
              );

              return BlocBuilder<LocaleCubit, LocaleState>(
                builder: (context, localeState) {
                  return MaterialApp.router(
                    title: 'App Skeleton',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.light,
                    darkTheme: AppTheme.dark,
                    themeMode: themeState.themeMode,
                    locale: localeState.locale,
                    supportedLocales: LocaleCubit.supported,

                    routerConfig: _router,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
