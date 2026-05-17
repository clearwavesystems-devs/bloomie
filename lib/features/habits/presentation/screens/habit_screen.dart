import 'package:bloomie/features/habits/presentation/widgets/bobbing_bunny.dart';
import 'package:bloomie/features/habits/presentation/widgets/floating_petals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/habits_cubit.dart';
import '../../cubit/habits_state.dart';
import '../../../duo/cubit/duo_cubit.dart';
import '../../../duo/cubit/duo_state.dart';
import '../../../garden/cubit/garden_cubit.dart';
import '../../../garden/cubit/garden_state.dart';
import '../../../profile/cubit/profile_cubit.dart';
import '../../../profile/cubit/profile_state.dart';
import '../../../shop/cubit/shop_cubit.dart';
import '../../../shop/cubit/shop_state.dart';
import '../widgets/habit_card.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/sync/sync_queue_service.dart';
import '../../../../core/sync/data_sync_service.dart';
import '../../../settings/presentation/widgets/sync_status_badge.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HabitsCubit>().loadHabits();
    context.read<DuoCubit>().loadDuoData();
    context.read<GardenCubit>().init();
    context.read<ProfileCubit>().loadProfile();
    context.read<ShopCubit>().loadShop(); // Load equipped accessories for pet
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      body: RefreshIndicator(
        onRefresh: () async {
          final syncQueue = context.read<SyncQueueService>();
          final dataSync = context.read<DataSyncService>();
          try {
            await syncQueue.forceSync();
            await dataSync.syncFromSupabase();
          } catch (e) {
            debugPrint('⚠️ HabitScreen: Manual sync failed: $e');
          }
          if (context.mounted) {
            context.read<HabitsCubit>().loadHabits();
            context.read<DuoCubit>().loadDuoData();
            context.read<GardenCubit>().init();
            context.read<ProfileCubit>().loadProfile();
            context.read<ShopCubit>().loadShop();
          }
        },
        color: const Color(0xFFE896B0),
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _HeroSection()),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: _ProgressCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: "Daily Habits",
                actionText: "see all",
                onAction: () => context.push('/habits'),
              ),
            ),
            _HabitList(),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: _AddHabitButton(),
              ),
            ),
            SliverToBoxAdapter(
              child: _SectionHeader(title: "Garden Growth", onAction: () {}),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: _WeeklyReportCard(),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileCubit>().state;
    int streak = 0;
    int blooms = 0;
    if (profileState is ProfileLoaded) {
      streak = profileState.user.streakDays;
      blooms = profileState.user.totalBlooms;
    }

    return Container(
      height: 380.h,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDDBE8), Color(0xFFFFF0F5)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Petals Animation
          Positioned.fill(
            child: FloatingPetals(containerWidth: 1.sw, containerHeight: 380.h),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '🌸 Bloomie',
                        style: GoogleFonts.baloo2(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE896B0),
                        ),
                      ),
                      Row(
                        children: [
                          const SyncStatusBadge(),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              SolarIconsOutline.bell,
                              color: const Color(0xFFE896B0),
                              size: 24.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      _StatPill(icon: '🔥', label: '$streak streak'),
                      SizedBox(width: 8.w),
                      _StatPill(icon: '🌸', label: '$blooms blooms'),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _PartnerStatusBadge(),
                ),
                const Spacer(),
                // Garden Ground
                Container(
                  height: 60.h,
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2B8CC).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ),
          ),

          // Bunnies and Plant — Reactive to Shop accessories & Habit mood
          Positioned(
            bottom: 30.h,
            left: 0,
            right: 0,
            child: BlocBuilder<GardenCubit, GardenState>(
              builder: (context, gardenState) {
                String plantEmoji = '🌹';
                String plantName = 'Our Rose';
                if (gardenState is GardenLoaded) {
                  plantEmoji = gardenState.currentPlant.emoji;
                  plantName = gardenState.currentPlant.name;
                }

                return BlocBuilder<ShopCubit, ShopState>(
                  builder: (context, shopState) {
                    // Find the equipped pet_accessory (if any)
                    String? equippedAccessory;
                    if (shopState is ShopLoaded) {
                      final equipped = shopState.items.where(
                        (i) => i.category == 'pet_accessory' && i.equipped,
                      );
                      if (equipped.isNotEmpty) {
                        equippedAccessory = equipped.first.id;
                      }
                    }

                    return BlocBuilder<HabitsCubit, HabitsState>(
                      builder: (context, habitsState) {
                        // Derive mood from today's completion rate
                        String mood = 'happy';
                        if (habitsState is HabitsLoaded) {
                          final rate = habitsState.todayCompletionRate;
                          if (rate >= 1.0) {
                            mood = 'sparkly'; // All done! Celebration mode
                          } else if (rate == 0.0) {
                            mood = 'meh'; // Nothing done yet
                          } else {
                            mood = 'happy'; // Making progress
                          }
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            BobbingBunny(
                              bodyColor: Colors.white,
                              earColor: const Color(0xFFFDDBE8),
                              cheekColor: const Color(0xFFFFC8DC),
                              size: 70,
                              mood: mood,
                              equippedAccessory: equippedAccessory,
                            ),
                            SizedBox(width: 20.w),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  plantEmoji,
                                  style: TextStyle(fontSize: 40.sp),
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  plantName,
                                  style: GoogleFonts.nunito(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFC07AD0),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 20.w),
                            BobbingBunny(
                              bodyColor: const Color(0xFFF2E8FF),
                              earColor: const Color(0xFFE8D4FF),
                              cheekColor: const Color(0xFFD4BFFF),
                              size: 70,
                              mirrorX: true,
                              mood: mood,
                              // Partner bunny doesn't wear accessories
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String icon;
  final String label;

  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Text(
        '$icon $label',
        style: GoogleFonts.nunito(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF3A2030),
        ),
      ),
    );
  }
}

class _PartnerStatusBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DuoCubit, DuoState>(
      builder: (context, state) {
        String message = 'Waiting for partner...';
        bool isOnline = false;

        if (state is DuoLoaded && state.partner != null) {
          isOnline = true; // Simplified for UI demo
          message = '${state.partner!.name} is online · 4/5 habits done';
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE896B0).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: isOnline ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                message,
                style: GoogleFonts.nunito(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3A2030),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitsCubit, HabitsState>(
      builder: (context, state) {
        double progress = 0.0;
        int completed = 0;
        int total = 0;

        if (state is HabitsLoaded) {
          total = state.habits.length;
          completed = state.habits
              .where((h) => h.currentCount >= h.targetCount)
              .length;
          progress = total > 0 ? completed / total : 0.0;
        }

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE896B0), Color(0xFFC07AD0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE896B0).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 70.w,
                height: 70.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      strokeCap: StrokeCap.round,
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: GoogleFonts.baloo2(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Great job, duo!',
                      style: GoogleFonts.baloo2(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'You\'ve completed $completed out of $total habits today.',
                      style: GoogleFonts.nunito(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    this.actionText = "See all",
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.baloo2(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3A2030),
            ),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(
              actionText,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFC07AD0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitsCubit, HabitsState>(
      builder: (context, state) {
        if (state is HabitsLoaded) {
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final habit = state.habits[index];
              return HabitCard(
                habit: habit,
                onToggle: () =>
                    context.read<HabitsCubit>().toggleHabitComplete(habit.id),
                partnerNote: habit.isSharedWithPartner
                    ? 'Mira also did this!'
                    : null,
              );
            }, childCount: state.habits.length),
          );
        }
        return const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _WeeklyReportCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mock data for visual excellence - in real app this would come from a Cubit
    final List<double> myProgress = [0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 0.3];
    final List<double> partnerProgress = [0.5, 0.4, 0.8, 0.6, 0.7, 0.4, 0.5];
    final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Overview',
                style: GoogleFonts.baloo2(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF3A2030),
                ),
              ),
              Text(
                '+12% this week',
                style: GoogleFonts.nunito(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 100.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                return _BarChartGroup(
                  day: days[index],
                  myProgress: myProgress[index],
                  partnerProgress: partnerProgress[index],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartGroup extends StatelessWidget {
  final String day;
  final double myProgress;
  final double partnerProgress;

  const _BarChartGroup({
    required this.day,
    required this.myProgress,
    required this.partnerProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 8.w,
              height: 60.h * myProgress,
              decoration: BoxDecoration(
                color: const Color(0xFFE896B0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(width: 4.w),
            Container(
              width: 8.w,
              height: 60.h * partnerProgress,
              decoration: BoxDecoration(
                color: const Color(0xFFC07AD0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          day,
          style: GoogleFonts.nunito(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _AddHabitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/add-habit'),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFDDBE8).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE896B0).withValues(alpha: 0.5),
            style: BorderStyle.solid,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '+ Add New Habit',
          style: GoogleFonts.baloo2(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFE896B0),
          ),
        ),
      ),
    );
  }
}
