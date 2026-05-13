import 'package:flutter/material.dart';

/// A custom animated bunny widget with bobbing + ear wiggle animations
class BobbingBunny extends StatefulWidget {
  final Color bodyColor;
  final Color earColor;
  final Color cheekColor;
  final bool mirrorX;
  final double size;
  final Duration bobbingDuration;

  const BobbingBunny({
    super.key,
    required this.bodyColor,
    required this.earColor,
    required this.cheekColor,
    this.mirrorX = false,
    this.size = 80,
    this.bobbingDuration = const Duration(milliseconds: 1800),
  });

  @override
  State<BobbingBunny> createState() => _BobbingBunnyState();
}

class _BobbingBunnyState extends State<BobbingBunny>
    with TickerProviderStateMixin {
  late AnimationController _bobbingController;
  late AnimationController _earController;
  late Animation<double> _bobbingAnim;
  late Animation<double> _earAnim;

  @override
  void initState() {
    super.initState();

    _bobbingController = AnimationController(
      vsync: this,
      duration: widget.bobbingDuration,
    )..repeat(reverse: true);

    _earController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _bobbingAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _bobbingController, curve: Curves.easeInOut),
    );

    _earAnim = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(parent: _earController, curve: Curves.easeInOut),
    );
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

  _BunnyPainter({
    required this.bodyColor,
    required this.earColor,
    required this.cheekColor,
    required this.earAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()..color = bodyColor;
    final earPaint = Paint()..color = earColor;
    final innerEarPaint = Paint()..color = cheekColor.withOpacity(0.6);
    final cheekPaint = Paint()..color = cheekColor.withOpacity(0.5);
    final eyePaint = Paint()..color = const Color(0xFF4A2040);
    final nosePaint = Paint()..color = const Color(0xFFE896B0);
    final whitePaint = Paint()..color = Colors.white;

    // ── Body ──────────────────────────────────────────────────────────────
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.72),
        width: w * 0.78,
        height: h * 0.48,
      ),
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

    // ── Eyes ──────────────────────────────────────────────────────────────
    canvas.drawCircle(Offset(w * 0.39, h * 0.40), w * 0.055, eyePaint);
    canvas.drawCircle(Offset(w * 0.61, h * 0.40), w * 0.055, eyePaint);
    // Eye shine
    canvas.drawCircle(Offset(w * 0.41, h * 0.38), w * 0.020, whitePaint);
    canvas.drawCircle(Offset(w * 0.63, h * 0.38), w * 0.020, whitePaint);

    // ── Nose ──────────────────────────────────────────────────────────────
    canvas.drawCircle(Offset(w * 0.5, h * 0.46), w * 0.040, nosePaint);

    // ── Cheeks ────────────────────────────────────────────────────────────
    canvas.drawCircle(Offset(w * 0.30, h * 0.46), w * 0.090, cheekPaint);
    canvas.drawCircle(Offset(w * 0.70, h * 0.46), w * 0.090, cheekPaint);

    // ── Tail ──────────────────────────────────────────────────────────────
    canvas.drawCircle(Offset(w * 0.82, h * 0.78), w * 0.090, whitePaint);
  }

  @override
  bool shouldRepaint(_BunnyPainter old) =>
      old.earAngle != earAngle ||
      old.bodyColor != bodyColor ||
      old.earColor != earColor;
}
