import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Floating petal particle system
class FloatingPetals extends StatefulWidget {
  final int petalCount;
  final double containerWidth;
  final double containerHeight;

  const FloatingPetals({
    super.key,
    this.petalCount = 12,
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  State<FloatingPetals> createState() => _FloatingPetalsState();
}

class _FloatingPetalsState extends State<FloatingPetals>
    with TickerProviderStateMixin {
  final List<_PetalParticle> _petals = [];
  late AnimationController _masterController;
  final _rng = math.Random(42);

  @override
  void initState() {
    super.initState();
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    for (int i = 0; i < widget.petalCount; i++) {
      _petals.add(_PetalParticle(
        controller: AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 3000 + _rng.nextInt(3000)),
        )..forward(from: _rng.nextDouble()),
        startX: _rng.nextDouble() * widget.containerWidth,
        driftX: (_rng.nextDouble() - 0.5) * 40,
        size: 6 + _rng.nextDouble() * 8,
        color: _petalColors[_rng.nextInt(_petalColors.length)],
        rotation: _rng.nextDouble() * math.pi * 2,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 4,
      ));
      _petals.last.controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _petals[i] = _petals[i].copyWith(
            startX: _rng.nextDouble() * widget.containerWidth,
          );
          _petals[i].controller.forward(from: 0);
        }
      });
    }
  }

  static const List<Color> _petalColors = [
    Color(0xFFE896B0),
    Color(0xFFC07AD0),
    Color(0xFFF4A7C0),
    Color(0xFFE8B4D0),
    Color(0xFFD4A0E8),
    Color(0xFFFDD0E4),
  ];

  @override
  void dispose() {
    _masterController.dispose();
    for (final p in _petals) {
      p.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _masterController,
        builder: (_, __) => CustomPaint(
          size: Size(widget.containerWidth, widget.containerHeight),
          painter: _PetalsPainter(
            petals: _petals,
            containerHeight: widget.containerHeight,
          ),
        ),
      ),
    );
  }
}

class _PetalParticle {
  final AnimationController controller;
  final double startX;
  final double driftX;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;

  _PetalParticle({
    required this.controller,
    required this.startX,
    required this.driftX,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });

  _PetalParticle copyWith({double? startX}) {
    return _PetalParticle(
      controller: controller,
      startX: startX ?? this.startX,
      driftX: driftX,
      size: size,
      color: color,
      rotation: rotation,
      rotationSpeed: rotationSpeed,
    );
  }
}

class _PetalsPainter extends CustomPainter {
  final List<_PetalParticle> petals;
  final double containerHeight;

  _PetalsPainter({required this.petals, required this.containerHeight});

  @override
  void paint(Canvas canvas, Size size) {
    for (final petal in petals) {
      final t = petal.controller.value;
      final y = containerHeight * t;
      final x = petal.startX + petal.driftX * math.sin(t * math.pi * 2);
      final alpha = t < 0.15
          ? (t / 0.15)
          : t > 0.85
              ? ((1.0 - t) / 0.15)
              : 1.0;

      final paint = Paint()
        ..color = petal.color.withOpacity(alpha * 0.8)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(petal.rotation + t * petal.rotationSpeed * math.pi * 2);

      // Draw a petal shape
      final path = Path();
      final s = petal.size;
      path.moveTo(0, -s);
      path.cubicTo(s * 0.6, -s * 0.6, s * 0.6, s * 0.6, 0, s * 0.4);
      path.cubicTo(-s * 0.6, s * 0.6, -s * 0.6, -s * 0.6, 0, -s);
      canvas.drawPath(path, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PetalsPainter oldDelegate) => true;
}
