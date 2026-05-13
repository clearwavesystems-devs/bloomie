import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../duo/presentation/widgets/bunny_widget.dart';

class GardenScene extends StatelessWidget {
  final String plantEmoji;
  final String plantName;
  final double growth;

  const GardenScene({
    super.key,
    required this.plantEmoji,
    required this.plantName,
    required this.growth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Ground
          Container(
            height: 40,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.ground,
              borderRadius: BorderRadius.vertical(top: Radius.elliptical(200, 30)),
            ),
          ),
          
          // Shared Plant
          Positioned(
            bottom: 30,
            child: Column(
              children: [
                Text(
                  plantEmoji,
                  style: const TextStyle(fontSize: 48),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds, curve: Curves.easeInOut),
                Text(
                  plantName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lavender,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          // Left Bunny (You)
          const Positioned(
            left: 40,
            bottom: 20,
            child: BunnyWidget(label: 'You', color: AppColors.primaryPink),
          ),
          
          // Right Bunny (Mira)
          const Positioned(
            right: 40,
            bottom: 20,
            child: BunnyWidget(label: 'Mira', color: AppColors.lavender),
          ),
        ],
      ),
    );
  }
}
