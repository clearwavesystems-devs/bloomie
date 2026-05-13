import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BunnyWidget extends StatelessWidget {
  final String label;
  final Color color;

  const BunnyWidget({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text('🐰', style: TextStyle(fontSize: 32)),
          ),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
         .moveY(begin: 0, end: -8, duration: 1.5.seconds, curve: Curves.easeInOut)
         .rotate(begin: -0.05, end: 0.05, duration: 1.5.seconds, curve: Curves.easeInOut),
      ],
    );
  }
}
