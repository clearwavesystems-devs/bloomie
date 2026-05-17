import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProgressRing extends StatelessWidget {
  final double percent;
  final String label;

  const ProgressRing({super.key, required this.percent, required this.label});

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 35.0,
      lineWidth: 7.0,
      percent: percent,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${(percent * 100).toInt()}%',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.7)),
          ),
        ],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      progressColor: Colors.white,
      animation: true,
      animationDuration: 1000,
    );
  }
}
