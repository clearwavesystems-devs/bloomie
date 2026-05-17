import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bloomie/core/theme/app_colors.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:bloomie/features/adventure/cubit/adventure_cubit.dart';
import 'package:bloomie/features/adventure/cubit/adventure_state.dart';
import 'package:bloomie/core/database/app_database.dart';

class AdventureScreen extends StatefulWidget {
  const AdventureScreen({super.key});

  @override
  State<AdventureScreen> createState() => _AdventureScreenState();
}

class _AdventureScreenState extends State<AdventureScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdventureCubit>().loadLands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1035),
      appBar: AppBar(
        title: Text(
          'Adventure Lands',
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(SolarIconsOutline.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<AdventureCubit, AdventureState>(
        builder: (context, state) {
          if (state is AdventureLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            );
          }

          if (state is AdventureError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (state is AdventureLoaded) {
            return _LandMap(
              lands: state.lands,
              currentLevel: state.currentLevel,
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

// ── Land Map ──────────────────────────────────

class _LandMap extends StatelessWidget {
  final List<AdventureLand> lands;
  final int currentLevel;

  const _LandMap({required this.lands, required this.currentLevel});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header Banner
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.all(20.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3D1A78), Color(0xFF6A2FA0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Journey',
                        style: GoogleFonts.baloo2(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Level $currentLevel Explorer',
                        style: GoogleFonts.nunito(
                          fontSize: 13.sp,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '${lands.where((l) => l.unlocked).length} of ${lands.length} lands unlocked',
                        style: GoogleFonts.nunito(
                          fontSize: 12.sp,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text('🗺️', style: TextStyle(fontSize: 48.sp)),
              ],
            ),
          ),
        ),

        // Land Cards (vertical path)
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final land = lands[index];
                final isLast = index == lands.length - 1;

                return Column(
                  children: [
                    _LandCard(
                      land: land,
                      currentLevel: currentLevel,
                    ),
                    if (!isLast)
                      _PathConnector(unlocked: land.unlocked),
                  ],
                );
              },
              childCount: lands.length,
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 80.h)),
      ],
    );
  }
}

// ── Path Connector ────────────────────────────

class _PathConnector extends StatelessWidget {
  final bool unlocked;
  const _PathConnector({required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: Center(
        child: Container(
          width: 3.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: unlocked
                ? AppColors.primaryPink.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ── Land Card ─────────────────────────────────

class _LandCard extends StatelessWidget {
  final AdventureLand land;
  final int currentLevel;

  const _LandCard({required this.land, required this.currentLevel});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = land.unlocked;
    final canUnlock = currentLevel >= land.requiredLevel;
    final bgColor = isUnlocked ? _unlockedBg(land.id) : const Color(0xFF2A1F45);
    final borderColor = isUnlocked
        ? AppColors.primaryPink.withValues(alpha: 0.5)
        : Colors.white.withValues(alpha: 0.08);

    return GestureDetector(
      onTap: isUnlocked
          ? () => _showLandDetail(context, land)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 0),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: AppColors.primaryPink.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Emoji badge
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  isUnlocked ? land.emoji : '🔒',
                  style: TextStyle(fontSize: 28.sp),
                ),
              ),
            ),
            SizedBox(width: 16.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUnlocked ? land.name : '???',
                    style: GoogleFonts.baloo2(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: isUnlocked ? Colors.white : Colors.white38,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    isUnlocked ? land.description : 'Reach Level ${land.requiredLevel} to unlock',
                    style: GoogleFonts.nunito(
                      fontSize: 11.sp,
                      color: isUnlocked
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.35),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isUnlocked) ...[
                    SizedBox(height: 8.h),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: land.progress,
                        minHeight: 6.h,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _progressColor(land.progress),
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${(land.progress * 100).toInt()}% explored',
                      style: GoogleFonts.nunito(
                        fontSize: 10.sp,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 10.w),

            // Status badge
            Column(
              children: [
                if (isUnlocked)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryPink, AppColors.lavender],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Explore',
                      style: GoogleFonts.nunito(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: canUnlock
                          ? Colors.amber.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: canUnlock
                            ? Colors.amber.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      'Lv.${land.requiredLevel}',
                      style: GoogleFonts.nunito(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: canUnlock ? Colors.amber : Colors.white30,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _unlockedBg(String id) {
    switch (id) {
      case 'land_meadow':  return const Color(0xFF1A3A1A);
      case 'land_forest':  return const Color(0xFF0D2D1A);
      case 'land_cave':    return const Color(0xFF1A1A35);
      case 'land_marsh':   return const Color(0xFF0D1F2D);
      case 'land_sky':     return const Color(0xFF1A2535);
      case 'land_cosmos':  return const Color(0xFF1A0D2D);
      default:             return const Color(0xFF2A1F45);
    }
  }

  Color _progressColor(double progress) {
    if (progress >= 1.0) return Colors.greenAccent;
    if (progress >= 0.5) return Colors.amber;
    return AppColors.primaryPink;
  }

  void _showLandDetail(BuildContext context, AdventureLand land) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<AdventureCubit>(),
        child: _LandDetailSheet(land: land),
      ),
    );
  }
}

// ── Land Detail Bottom Sheet ──────────────────

class _LandDetailSheet extends StatelessWidget {
  final AdventureLand land;
  const _LandDetailSheet({required this.land});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1040),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 24.h),

          // Hero emoji
          Text(land.emoji, style: TextStyle(fontSize: 64.sp)),
          SizedBox(height: 12.h),

          Text(
            land.name,
            style: GoogleFonts.baloo2(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            land.description,
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),

          // Progress ring area
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoChip(label: 'Progress', value: '${(land.progress * 100).toInt()}%', emoji: '🗺️'),
              SizedBox(width: 16.w),
              _InfoChip(
                label: 'Status',
                value: land.progress >= 1.0 ? 'Mastered!' : 'Exploring',
                emoji: land.progress >= 1.0 ? '🏆' : '⚔️',
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: land.progress,
              minHeight: 12.h,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                land.progress >= 1.0 ? Colors.greenAccent : AppColors.primaryPink,
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Explore button
          if (land.progress < 1.0)
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: () async {
                  await context.read<AdventureCubit>().exploreLand(land);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryPink, AppColors.lavender],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('⚔️', style: TextStyle(fontSize: 18.sp)),
                        SizedBox(width: 10.w),
                        Text(
                          'Explore +10%',
                          style: GoogleFonts.baloo2(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '+30 XP',
                          style: GoogleFonts.nunito(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
              ),
              child: Text(
                '🏆 Land Fully Mastered!',
                style: GoogleFonts.baloo2(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;

  const _InfoChip({required this.label, required this.value, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 20.sp)),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.baloo2(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 10.sp,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}
