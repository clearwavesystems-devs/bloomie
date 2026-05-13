import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../cubit/profile_cubit.dart';
import '../../cubit/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
            final user = state.user;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.pinkLight,
                    child: Text(user.avatarEmoji, style: const TextStyle(fontSize: 50)),
                  ),
                  const SizedBox(height: 16),
                  Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(context.read<ProfileCubit>().getLevelTitle(user.level), 
                    style: const TextStyle(color: AppColors.primaryPink, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  _StatGrid(user: user),
                  const SizedBox(height: 30),
                  const _SettingsSection(),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final dynamic user;
  const _StatGrid({required this.user});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(label: 'Level', value: '${user.level}', icon: '⭐'),
        _StatCard(label: 'XP', value: '${user.xp}', icon: '✨'),
        _StatCard(label: 'Blooms', value: '${user.totalBlooms}', icon: '🌸'),
        _StatCard(label: 'Streak', value: '${user.streakDays} days', icon: '🔥'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$icon $label', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.notifications_active_outlined),
          title: const Text('Notifications'),
          trailing: Switch(value: true, onChanged: (v) {}),
        ),
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('App Theme'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Help & Support'),
          onTap: () {},
        ),
      ],
    );
  }
}
