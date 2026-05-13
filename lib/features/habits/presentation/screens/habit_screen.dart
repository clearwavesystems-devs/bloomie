import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../cubit/habits_cubit.dart';
import '../../cubit/habits_state.dart';
import '../../../duo/cubit/duo_cubit.dart';
import '../../../duo/cubit/duo_state.dart';
import '../../../garden/cubit/garden_cubit.dart';
import '../../../garden/cubit/garden_state.dart';
import '../../../profile/cubit/profile_cubit.dart';
import '../widgets/garden_scene.dart';
import '../widgets/habit_card.dart';
import '../widgets/progress_ring.dart';
import '../../../duo/presentation/widgets/partner_badge.dart';
import '../widgets/falling_petals.dart';
import 'package:go_router/go_router.dart';

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
    context.read<GardenCubit>().loadGarden('rose_id');
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _HeroSection()),
              SliverToBoxAdapter(child: _ProgressCard()),
              SliverToBoxAdapter(child: _HabitListHeader()),
              _HabitList(),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _BottomNav()),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.heroGradient,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Stack(
        children: [
          const Positioned.fill(child: FallingPetals()),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🌸 Bloomie',
                      style: Theme.of(
                        context,
                      ).textTheme.displayLarge?.copyWith(fontSize: 28, color: AppColors.primaryPink),
                    ),
                    const Icon(Icons.settings_outlined, color: AppColors.textDark),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatPill(icon: '🔥', label: '12 streak'),
                    const SizedBox(width: 8),
                    _StatPill(icon: '🌸', label: '680 blooms'),
                  ],
                ),
                const SizedBox(height: 16),
                BlocBuilder<DuoCubit, DuoState>(
                  builder: (context, state) {
                    if (state is DuoLoaded && state.partner != null) {
                      return PartnerBadge(partnerName: state.partner!.name, statusText: 'watered 2h ago');
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<GardenCubit, GardenState>(
                  builder: (context, state) {
                    if (state is GardenLoaded) {
                      return GardenScene(
                        plantEmoji: state.currentPlant.emoji,
                        plantName: state.currentPlant.name,
                        growth: state.currentPlant.growthPercent,
                      );
                    }
                    return const GardenScene(plantEmoji: '🌹', plantName: 'Our Rose', growth: 0.5);
                  },
                ),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Text(
        '$icon $label',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textDark),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryPink, AppColors.lavender],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: AppColors.primaryPink.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: BlocBuilder<HabitsCubit, HabitsState>(
        builder: (context, state) {
          double percent = 0.0;
          int done = 0;
          int total = 0;

          if (state is HabitsLoaded) {
            total = state.habits.length;
            done = state.habits.where((h) => h.currentCount >= h.targetCount).length;
            percent = total > 0 ? done / total : 0.0;
          }

          return Row(
            children: [
              ProgressRing(percent: percent, label: 'bloomed'),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Blooming together! 💑',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    Text(
                      'You $done/$total · Mira 4/5',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HabitListHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Your Habits', style: Theme.of(context).textTheme.titleLarge),
          TextButton(
            onPressed: () {},
            child: const Text(
              '+ Add',
              style: TextStyle(color: AppColors.lavender, fontWeight: FontWeight.w800),
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
                onToggle: () => context.read<HabitsCubit>().toggleHabitComplete(habit.id),
                partnerNote: habit.isSharedWithPartner ? 'Mira also did this!' : null,
              );
            }, childCount: state.habits.length),
          );
        }
        return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.creamBg.withOpacity(0.95),
        border: Border(top: BorderSide(color: AppColors.primaryPink.withOpacity(0.1))),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.dashboard_rounded, label: 'Home', isSelected: false, onTap: () => context.go('/home')),
          _NavItem(
            icon: Icons.check_circle_rounded,
            label: 'Habits',
            isSelected: true,
            onTap: () => context.go('/habits'),
          ),
          _NavItem(icon: Icons.favorite_rounded, label: 'Duo', isSelected: false, onTap: () => context.go('/duo')),
          _NavItem(
            icon: Icons.add_circle_rounded,
            label: 'Add',
            isSelected: false,
            isAction: true,
            onTap: () => context.push('/add-habit'),
          ),
          _NavItem(icon: Icons.park_rounded, label: 'Garden', isSelected: false, onTap: () => context.go('/garden')),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            isSelected: false,
            onTap: () => context.go('/profile'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isAction;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: _buildContent(context));
  }

  Widget _buildContent(BuildContext context) {
    if (isAction) {
      return Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [AppColors.primaryPink, AppColors.lavender]),
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isSelected ? AppColors.lavender : AppColors.textMuted),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isSelected ? AppColors.lavender : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
