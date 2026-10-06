import 'package:bloomie/features/garden/cubit/garden_cubit.dart';
import 'package:bloomie/features/garden/cubit/garden_state.dart';
import 'package:bloomie/features/shop/cubit/shop_cubit.dart';
import 'package:bloomie/features/shop/cubit/shop_state.dart';
import 'package:bloomie/core/theme/garden_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:solar_icons/solar_icons.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GardenCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GardenCubit, GardenState>(
      builder: (context, gardenState) {
        // Get the current shop state to check equipped garden skin
        final shopState = context.watch<ShopCubit>().state;
        GardenTheme currentTheme;

        if (shopState is ShopLoaded) {
          final equippedSkin = shopState.items.where((i) =>
            i.category == 'plant_skin' && i.equipped).firstOrNull;

          // Map shop item ID to theme
          currentTheme = GardenThemes.forPlantSkin(equippedSkin?.id ?? 'default');
        } else {
          currentTheme = GardenThemes.defaultTheme;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'My Garden',
              style: TextStyle(
                color: currentTheme.primaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: currentTheme.primaryText),
          ),
          body: Container(
            decoration: BoxDecoration(
              color: currentTheme.backgroundColor,
              // Apply gradient if theme has one
              gradient: currentTheme.gradientColors.isNotEmpty
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: currentTheme.gradientColors,
                    )
                  : null,
            ),
            child: BlocBuilder<GardenCubit, GardenState>(
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
                  return _PlantCard(
                    emoji: plant.emoji,
                    name: plant.name,
                    growth: plant.growthPercent,
                    isLocked: false,
                  );
                }
                return const _PlantCard(
                  emoji: '🌻',
                  name: 'Sunflower',
                  growth: 0,
                  isLocked: true,
                );
              },
            );
          } else if (state is GardenError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🪴', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<GardenCubit>().init(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
          ),
    );
    });
  }
}

class _PlantCard extends StatelessWidget {
  final String emoji, name;
  final double growth;
  final bool isLocked;

  const _PlantCard({
    required this.emoji,
    required this.name,
    required this.growth,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GardenCubit, GardenState>(
      builder: (context, gardenState) {
        // Get the current shop state to check equipped garden skin
        final shopState = context.watch<ShopCubit>().state;
        GardenTheme currentTheme;

        if (shopState is ShopLoaded) {
          final equippedSkin = shopState.items.where((i) =>
            i.category == 'plant_skin' && i.equipped).firstOrNull;

          // Map shop item ID to theme
          currentTheme = GardenThemes.forPlantSkin(equippedSkin?.id ?? 'default');
        } else {
          currentTheme = GardenThemes.defaultTheme;
        }

        return Container(
          decoration: BoxDecoration(
            color: currentTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 48,
                      color: isLocked ? Colors.grey.withValues(alpha: 0.3) : null,
                    ),
                  ),
                  if (isLocked)
                    const Icon(SolarIconsOutline.lock, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
                ),
              ),
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
                Text(
                  '${(growth * 100).toInt()}% grown',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6) ?? Colors.grey,
                  ),
                ),
              ] else
                const Text(
                  'Locked',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        );
      },
    );
  }
}
