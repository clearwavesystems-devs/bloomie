import 'package:bloomie/features/duo/cubit/duo_cubit.dart';
import 'package:bloomie/features/duo/cubit/duo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';

class DuoScreen extends StatefulWidget {
  const DuoScreen({super.key});

  @override
  State<DuoScreen> createState() => _DuoScreenState();
}

class _DuoScreenState extends State<DuoScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DuoCubit>().loadDuoData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Duo Mode')),
      body: BlocBuilder<DuoCubit, DuoState>(
        builder: (context, state) {
          if (state is DuoLoaded && state.partner != null) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _PartnerCard(partner: state.partner!),
                  const SizedBox(height: 20),
                  _WeeklyComparison(report: state.weeklyReport),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lavender,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () => context.read<DuoCubit>().sendPetal(),
                    icon: const Text('🌸'),
                    label: const Text('Send a petal to Mira'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Invite a partner to start!'));
        },
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final dynamic partner;

  const _PartnerCard({required this.partner});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.lavLight,
            child: Text(partner.avatarEmoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(partner.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  'Active ${partner.lastActiveAt.hour}:${partner.lastActiveAt.minute}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: partner.todayHabitsDone / partner.todayHabitsTotal,
                  backgroundColor: AppColors.lavLight,
                  valueColor: const AlwaysStoppedAnimation(AppColors.lavender),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyComparison extends StatelessWidget {
  final Map<String, List<double>> report;

  const _WeeklyComparison({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Text('Weekly Progress Comparison', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(width: 8, height: report['you']![i] * 50, color: AppColors.primaryPink),
                      const SizedBox(width: 2),
                      Container(width: 8, height: report['partner']![i] * 50, color: AppColors.lavender),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][i], style: const TextStyle(fontSize: 10)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
