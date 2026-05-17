import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Call authentication check after the premium 1.8-second brand splash animation!
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 1800));
      if (mounted) {
        context.read<AuthCubit>().checkSession();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          context.go('/');
        } else if (state is AuthUnauthenticated || state is AuthError) {
          final prefs = await SharedPreferences.getInstance();
          final hasSeen = prefs.getBool('has_seen_onboarding') ?? false;
          if (context.mounted) {
            if (hasSeen) {
              context.go('/auth');
            } else {
              context.go('/onboarding');
            }
          }
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF5F0), Color(0xFFFFF2FA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Beautiful Pulsing Logo Emojis
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.primaryPink.withValues(alpha: 0.15), blurRadius: 24, spreadRadius: 4),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text('🌸', style: TextStyle(fontSize: 56.sp)),
                ),
              ),
              SizedBox(height: 24.h),

              // Title
              Text(
                'Bloomie',
                style: GoogleFonts.baloo2(
                  fontSize: 38.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryPink,
                  letterSpacing: 1,
                ),
              ),

              // Subtitle
              Text(
                'Grow every single day 🌱',
                style: GoogleFonts.nunito(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textMuted),
              ),
              SizedBox(height: 48.h),

              // Premium loader
              SizedBox(
                width: 32.w,
                height: 32.w,
                child: const CircularProgressIndicator(color: AppColors.primaryPink, strokeWidth: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
