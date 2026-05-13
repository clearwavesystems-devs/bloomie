import 'package:bloomie/features/garden/cubit/garden_cubit.dart';
import 'package:bloomie/features/garden/cubit/garden_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Garden')),
      body: BlocBuilder<GardenCubit, GardenState>(
        builder: (context, state) {
          if (state is GardenLoaded) {
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: state.history.length + 1,
              itemBuilder: (context, index) {
                if (index < state.history.length) {
                  final plant = state.history[index];
                  return _PlantCard(emoji: plant.emoji, name: plant.name, growth: plant.growthPercent, isLocked: false);
                }
                return const _PlantCard(emoji: '🌻', name: 'Sunflower', growth: 0, isLocked: true);
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final String emoji, name;
  final double growth;
  final bool isLocked;

  const _PlantCard({required this.emoji, required this.name, required this.growth, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Text(emoji, style: TextStyle(fontSize: 48, color: isLocked ? Colors.grey.withOpacity(0.3) : null)),
              if (isLocked) const Icon(Icons.lock_outline, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (!isLocked) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(
                value: growth,
                backgroundColor: AppColors.pinkLight,
                valueColor: const AlwaysStoppedAnimation(AppColors.primaryPink),
              ),
            ),
            const SizedBox(height: 4),
            Text('${(growth * 100).toInt()}% grown', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ] else
            const Text('Locked', style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
