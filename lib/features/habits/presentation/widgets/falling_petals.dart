import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FallingPetals extends StatelessWidget {
  const FallingPetals({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(15, (index) {
        final random = Random();
        final left = random.nextDouble() * 1.0;
        final duration = 8 + random.nextDouble() * 7;
        final delay = random.nextDouble() * 10;

        return Positioned(
          left: MediaQuery.of(context).size.width * left,
          top: -20,
          child: const Text('🌸', style: TextStyle(fontSize: 14))
              .animate(onPlay: (controller) => controller.repeat())
              .moveY(
                begin: 0,
                end: MediaQuery.of(context).size.height * 0.4,
                duration: duration.seconds,
                delay: delay.seconds,
                curve: Curves.linear,
              )
              .rotate(begin: 0, end: 2 * pi, duration: duration.seconds)
              .fadeOut(begin: 1, duration: (duration * 0.2).seconds, delay: (duration * 0.8).seconds),
        );
      }),
    );
  }
}
