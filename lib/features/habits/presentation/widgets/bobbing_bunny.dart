import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A custom animated bunny widget with bobbing + ear wiggle animations,
/// supporting dynamic emotional states and custom equipped accessories.
class BobbingBunny extends StatefulWidget {
  final Color bodyColor;
  final Color earColor;
  final Color cheekColor;
  final bool mirrorX;
  final double size;
  final Duration bobbingDuration;
  final String mood; // 'happy' | 'sparkly' | 'meh' | 'sleeping'
  final String? equippedAccessory; // 'acc_bow' | 'acc_crown' | 'acc_hat' | 'acc_scarf' | 'acc_glasses' | 'acc_wings' | 'acc_ribbon'

  const BobbingBunny({
    super.key,
    required this.bodyColor,
    required this.earColor,
    required this.cheekColor,
    this.mirrorX = false,
    this.size = 80,
    this.bobbingDuration = const Duration(milliseconds: 1800),
    this.mood = 'happy',
    this.equippedAccessory,
  });

  @override
  State<BobbingBunny> createState() => _BobbingBunnyState();
}

class _BobbingBunnyState extends State<BobbingBunny> with TickerProviderStateMixin {
  late AnimationController _bobbingController;
  late AnimationController _earController;
  late Animation<double> _bobbingAnim;
  late Animation<double> _earAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didUpdateWidget(covariant BobbingBunny oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood || oldWidget.bobbingDuration != widget.bobbingDuration) {
      _bobbingController.dispose();
      _earController.dispose();
      _initAnimations();
    }
  }

  void _initAnimations() {
    // Dynamic animation speeds depending on mood!
    Duration bobDuration = widget.bobbingDuration;
    double bobHeight = -8.0;

    if (widget.mood == 'sparkly') {
      bobDuration = const Duration(milliseconds: 1000); // Super fast happy bobbing!
      bobHeight = -12.0;
    } else if (widget.mood == 'sleeping') {
      bobDuration = const Duration(milliseconds: 3000); // Slow, breathing-like bobbing!
      bobHeight = -3.0;
    }

    _bobbingController = AnimationController(vsync: this, duration: bobDuration)..repeat(reverse: true);
    _earController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);

    _bobbingAnim = Tween<double>(
      begin: 0,
      end: bobHeight,
    ).animate(CurvedAnimation(parent: _bobbingController, curve: Curves.easeInOut));

    _earAnim = Tween<double>(
      begin: widget.mood == 'sleeping' ? -0.02 : -0.08,
      end: widget.mood == 'sleeping' ? 0.02 : 0.08,
    ).animate(CurvedAnimation(parent: _earController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bobbingController.dispose();
    _earController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bobbingAnim, _earAnim]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bobbingAnim.value),
          child: Transform.scale(
            scaleX: widget.mirrorX ? -1 : 1,
            child: CustomPaint(
              size: Size(widget.size, widget.size * 1.3),
              painter: _BunnyPainter(
                bodyColor: widget.bodyColor,
                earColor: widget.earColor,
                cheekColor: widget.cheekColor,
                earAngle: _earAnim.value,
                mood: widget.mood,
                equippedAccessory: widget.equippedAccessory,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BunnyPainter extends CustomPainter {
  final Color bodyColor;
  final Color earColor;
  final Color cheekColor;
  final double earAngle;
  final String mood;
  final String? equippedAccessory;

  _BunnyPainter({
    required this.bodyColor,
    required this.earColor,
    required this.cheekColor,
    required this.earAngle,
    required this.mood,
    required this.equippedAccessory,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()..color = bodyColor;
    final earPaint = Paint()..color = earColor;
    final innerEarPaint = Paint()..color = cheekColor.withValues(alpha: 0.6);
    final cheekPaint = Paint()..color = cheekColor.withValues(alpha: 0.5);
    final eyePaint = Paint()..color = const Color(0xFF4A2040);
    final nosePaint = Paint()..color = const Color(0xFFE896B0);
    final whitePaint = Paint()..color = Colors.white;

    // ── Accessory: Fairy Wings (Drawn behind body) ──────────────────
    if (equippedAccessory == 'acc_wings') {
      final wingPaint = Paint()..color = const Color(0xFFE0F7FA).withValues(alpha: 0.85);
      final wingBorder = Paint()
        ..color = const Color(0xFF80DEEA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Left wing
      final leftWingPath = Path()
        ..moveTo(w * 0.40, h * 0.65)
        ..quadraticBezierTo(w * 0.05, h * 0.45, w * 0.02, h * 0.60)
        ..quadraticBezierTo(w * 0.05, h * 0.80, w * 0.40, h * 0.75)
        ..close();
      canvas.drawPath(leftWingPath, wingPaint);
      canvas.drawPath(leftWingPath, wingBorder);

      // Right wing
      final rightWingPath = Path()
        ..moveTo(w * 0.60, h * 0.65)
        ..quadraticBezierTo(w * 0.95, h * 0.45, w * 0.98, h * 0.60)
        ..quadraticBezierTo(w * 0.95, h * 0.80, w * 0.60, h * 0.75)
        ..close();
      canvas.drawPath(rightWingPath, wingPaint);
      canvas.drawPath(rightWingPath, wingBorder);
    }

    // ── Body ──────────────────────────────────────────────────────────────
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.72), width: w * 0.78, height: h * 0.48),
      Radius.circular(w * 0.38),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // ── Head ──────────────────────────────────────────────────────────────
    canvas.drawCircle(Offset(w * 0.5, h * 0.42), w * 0.30, bodyPaint);

    // ── Left Ear ──────────────────────────────────────────────────────────
    canvas.save();
    canvas.translate(w * 0.32, h * 0.18);
    canvas.rotate(earAngle - 0.15);
    final leftEarRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.16, height: h * 0.30),
      Radius.circular(w * 0.10),
    );
    canvas.drawRRect(leftEarRect, earPaint);
    final leftInnerEar = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, h * 0.02), width: w * 0.08, height: h * 0.20),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(leftInnerEar, innerEarPaint);
    
    // Ribbon accessory on ear
    if (equippedAccessory == 'acc_ribbon') {
      final ribbonPaint = Paint()..color = const Color(0xFFFFB74D); // Gold Silk
      canvas.drawCircle(Offset(-w * 0.02, -h * 0.08), w * 0.04, ribbonPaint);
    }
    canvas.restore();

    // ── Right Ear ─────────────────────────────────────────────────────────
    canvas.save();
    canvas.translate(w * 0.68, h * 0.18);
    canvas.rotate(-earAngle + 0.15);
    final rightEarRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.16, height: h * 0.30),
      Radius.circular(w * 0.10),
    );
    canvas.drawRRect(rightEarRect, earPaint);
    final rightInnerEar = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, h * 0.02), width: w * 0.08, height: h * 0.20),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(rightInnerEar, innerEarPaint);
    canvas.restore();

    // ── Cheeks ────────────────────────────────────────────────────────────
    if (mood != 'sleeping') {
      canvas.drawCircle(Offset(w * 0.30, h * 0.46), w * 0.090, cheekPaint);
      canvas.drawCircle(Offset(w * 0.70, h * 0.46), w * 0.090, cheekPaint);
    }

    // ── Eyes (Reacting to Mood!) ──────────────────────────────────────────
    if (mood == 'sleeping') {
      // Draw sleeping curving-down eyes "u u"
      final sleepingPaint = Paint()
        ..color = const Color(0xFF4A2040)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      final leftEyePath = Path()
        ..moveTo(w * 0.34, h * 0.39)
        ..quadraticBezierTo(w * 0.39, h * 0.43, w * 0.44, h * 0.39);
      canvas.drawPath(leftEyePath, sleepingPaint);

      final rightEyePath = Path()
        ..moveTo(w * 0.56, h * 0.39)
        ..quadraticBezierTo(w * 0.61, h * 0.43, w * 0.66, h * 0.39);
      canvas.drawPath(rightEyePath, sleepingPaint);
    } else if (mood == 'sparkly') {
      // Sparkling stars or sparkling circular eyes!
      canvas.drawCircle(Offset(w * 0.39, h * 0.40), w * 0.065, eyePaint);
      canvas.drawCircle(Offset(w * 0.61, h * 0.40), w * 0.065, eyePaint);

      // Star-like dual sparkles
      canvas.drawCircle(Offset(w * 0.41, h * 0.37), w * 0.025, whitePaint);
      canvas.drawCircle(Offset(w * 0.37, h * 0.42), w * 0.015, whitePaint);
      canvas.drawCircle(Offset(w * 0.63, h * 0.37), w * 0.025, whitePaint);
      canvas.drawCircle(Offset(w * 0.59, h * 0.42), w * 0.015, whitePaint);
    } else {
      // Normal happy/meh eyes
      canvas.drawCircle(Offset(w * 0.39, h * 0.40), w * 0.055, eyePaint);
      canvas.drawCircle(Offset(w * 0.61, h * 0.40), w * 0.055, eyePaint);
      // Eye shine
      canvas.drawCircle(Offset(w * 0.41, h * 0.38), w * 0.020, whitePaint);
      canvas.drawCircle(Offset(w * 0.63, h * 0.38), w * 0.020, whitePaint);
    }

    // ── Nose & Mouth ──────────────────────────────────────────────────────
    if (mood == 'sleeping') {
      // Draw peaceful tiny sleeping flat nose
      canvas.drawCircle(Offset(w * 0.5, h * 0.46), w * 0.025, nosePaint);
    } else {
      canvas.drawCircle(Offset(w * 0.5, h * 0.46), w * 0.040, nosePaint);
      // Happy curved little mouth
      final mouthPaint = Paint()
        ..color = const Color(0xFF4A2040)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      final mouthPath = Path()
        ..moveTo(w * 0.47, h * 0.49)
        ..quadraticBezierTo(w * 0.50, h * 0.52, w * 0.53, h * 0.49);
      canvas.drawPath(mouthPath, mouthPaint);
    }

    // ── Tail ──────────────────────────────────────────────────────────────
    canvas.drawCircle(Offset(w * 0.82, h * 0.78), w * 0.090, whitePaint);

    // ── Accessory: Cozy Scarf (Neck area) ────────────────────────────
    if (equippedAccessory == 'acc_scarf') {
      final scarfPaint = Paint()..color = const Color(0xFFCE93D8); // Lavender Scarf
      final scarfBorder = Paint()
        ..color = const Color(0xFFAB47BC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final collarRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.54, w * 0.56, h * 0.08),
        Radius.circular(w * 0.04),
      );
      canvas.drawRRect(collarRect, scarfPaint);
      canvas.drawRRect(collarRect, scarfBorder);

      // Hanging scarf tail
      final tailRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.32, h * 0.62, w * 0.12, h * 0.18),
        Radius.circular(w * 0.02),
      );
      canvas.drawRRect(tailRect, scarfPaint);
      canvas.drawRRect(tailRect, scarfBorder);
    }

    // ── Accessory: Pink Bow (Neck area) ──────────────────────────────
    if (equippedAccessory == 'acc_bow') {
      final bowPaint = Paint()..color = const Color(0xFFF48FB1); // Pastel Pink
      final knotPaint = Paint()..color = const Color(0xFFF06292); // Deeper Pink

      // Left bow wing
      final leftWing = Path()
        ..moveTo(w * 0.50, h * 0.58)
        ..lineTo(w * 0.40, h * 0.53)
        ..lineTo(w * 0.40, h * 0.63)
        ..close();
      canvas.drawPath(leftWing, bowPaint);

      // Right bow wing
      final rightWing = Path()
        ..moveTo(w * 0.50, h * 0.58)
        ..lineTo(w * 0.60, h * 0.53)
        ..lineTo(w * 0.60, h * 0.63)
        ..close();
      canvas.drawPath(rightWing, bowPaint);

      // Center knot
      canvas.drawCircle(Offset(w * 0.50, h * 0.58), w * 0.035, knotPaint);
    }

    // ── Accessory: Star Glasses (Over eyes) ──────────────────────────
    if (equippedAccessory == 'acc_glasses') {
      final framePaint = Paint()
        ..color = const Color(0xFFFFEB3B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      // Draw Star left lens centered at w * 0.39, h * 0.40
      _drawStarFrame(canvas, Offset(w * 0.39, h * 0.40), w * 0.09, framePaint);
      // Draw Star right lens centered at w * 0.61, h * 0.40
      _drawStarFrame(canvas, Offset(w * 0.61, h * 0.40), w * 0.09, framePaint);

      // Bridge line
      canvas.drawLine(Offset(w * 0.47, h * 0.40), Offset(w * 0.53, h * 0.40), framePaint);
    }

    // ── Accessory: Flower Crown (On top of head) ─────────────────────
    if (equippedAccessory == 'acc_crown') {
      final f1 = Paint()..color = const Color(0xFFFFF176); // Yellow Flower
      final f2 = Paint()..color = const Color(0xFFF06292); // Pink Flower
      final f3 = Paint()..color = const Color(0xFF4DD0E1); // Cyan Flower
      final fCenter = Paint()..color = Colors.white;

      canvas.drawCircle(Offset(w * 0.38, h * 0.22), w * 0.05, f1);
      canvas.drawCircle(Offset(w * 0.38, h * 0.22), w * 0.02, fCenter);

      canvas.drawCircle(Offset(w * 0.50, h * 0.18), w * 0.06, f2);
      canvas.drawCircle(Offset(w * 0.50, h * 0.18), w * 0.025, fCenter);

      canvas.drawCircle(Offset(w * 0.62, h * 0.22), w * 0.05, f3);
      canvas.drawCircle(Offset(w * 0.62, h * 0.22), w * 0.02, fCenter);
    }

    // ── Accessory: Sun Hat (On top of head) ──────────────────────────
    if (equippedAccessory == 'acc_hat') {
      final hatPaint = Paint()..color = const Color(0xFFFFECB3); // Straw Hat Yellow
      final bandPaint = Paint()..color = const Color(0xFFE91E63); // Crimson band

      // Hat brim oval
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.22), width: w * 0.85, height: h * 0.08),
        hatPaint,
      );

      // Hat crown arch
      final hatCrownPath = Path()
        ..moveTo(w * 0.22, h * 0.22)
        ..quadraticBezierTo(w * 0.25, h * 0.10, w * 0.50, h * 0.09)
        ..quadraticBezierTo(w * 0.75, h * 0.10, w * 0.78, h * 0.22)
        ..close();
      canvas.drawPath(hatCrownPath, hatPaint);

      // Hat ribbon band
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.21), width: w * 0.65, height: h * 0.02),
        bandPaint,
      );
    }
  }

  void _drawStarFrame(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      double angle1 = (i * 4 * 3.14159 / 5) - 3.14159 / 2;
      double x = center.dx + size * 0.55 * math.cos(angle1);
      double y = center.dy + size * 0.55 * math.sin(angle1);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BunnyPainter old) =>
      old.earAngle != earAngle ||
      old.bodyColor != bodyColor ||
      old.earColor != earColor ||
      old.mood != mood ||
      old.equippedAccessory != equippedAccessory;
}
