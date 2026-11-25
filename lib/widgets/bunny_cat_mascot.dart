import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/weather_model.dart';

/// Animated pastel Bunny & Cat duo illustration drawn with CustomPainter.
/// Continuously animates (gentle breathing, ear wiggle, weather particles)
/// and smoothly transitions props (umbrella opening, scarves, fog, sun/moon)
/// whenever [category] or [isDay] changes.
class BunnyCatMascot extends StatefulWidget {
  final WeatherCategory category;
  final bool isDay;
  final double size;

  const BunnyCatMascot({
    super.key,
    required this.category,
    this.isDay = true,
    this.size = 160,
  });

  @override
  State<BunnyCatMascot> createState() => _BunnyCatMascotState();
}

class _BunnyCatMascotState extends State<BunnyCatMascot>
    with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final AnimationController _transitionController;

  WeatherCategory? _previousCategory;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
      value: 1.0,
    );
  }

  @override
  void didUpdateWidget(covariant BunnyCatMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category ||
        oldWidget.isDay != widget.isDay) {
      _previousCategory = oldWidget.category;
      _transitionController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idleController, _transitionController]),
        builder: (context, _) {
          return CustomPaint(
            painter: _BunnyAndCatPainter(
              category: widget.category,
              previousCategory: _previousCategory,
              isDay: widget.isDay,
              idleProgress: _idleController.value,
              transitionProgress: Curves.easeOutBack
                  .transform(_transitionController.value.clamp(0.0, 1.0)),
            ),
          );
        },
      ),
    );
  }
}

class _BunnyAndCatPainter extends CustomPainter {
  final WeatherCategory category;
  final WeatherCategory? previousCategory;
  final bool isDay;
  final double idleProgress;
  final double transitionProgress;

  _BunnyAndCatPainter({
    required this.category,
    required this.previousCategory,
    required this.isDay,
    required this.idleProgress,
    required this.transitionProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final phase = idleProgress * 2 * math.pi;
    final bobY = math.sin(phase) * h * 0.015;
    final catBobY = math.sin(phase + 0.8) * h * 0.015;
    final earWiggle = math.sin(phase * 2) * 0.04;

    // Soft pastel aura behind both characters
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.80),
          const Color(0xFFFFD8EA).withValues(alpha: 0.40),
          const Color(0xFFCDE9FF).withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(w * 0.5, h * 0.60), radius: w * 0.48),
      );
    canvas.drawCircle(Offset(w * 0.5, h * 0.60), w * 0.48, auraPaint);

    _drawWeatherBackdrop(canvas, w, h, phase);

    // Draw Bunny (left) and Cat (right) side-by-side with gentle breathing
    _drawBunny(
      canvas,
      w,
      h,
      centerX: w * 0.32,
      baseY: h * 0.64 + bobY,
      earWiggle: earWiggle,
    );
    _drawCat(
      canvas,
      w,
      h,
      centerX: w * 0.69,
      baseY: h * 0.66 + catBobY,
      tailSwing: math.sin(phase) * 0.06,
    );

    _drawForegroundProp(canvas, w, h, phase);
  }

  void _drawBunny(
    Canvas canvas,
    double w,
    double h, {
    required double centerX,
    required double baseY,
    required double earWiggle,
  }) {
    final furPaint = Paint()..color = const Color(0xFFFFFCFE);
    final innerEarPaint = Paint()..color = const Color(0xFFFFC1DF);
    final outlinePaint = Paint()
      ..color = const Color(0xFF7D6B8E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.015
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Long Bunny Ears with gentle wiggle
    canvas.save();
    canvas.translate(centerX - w * 0.075, baseY - h * 0.20);
    canvas.rotate(-0.16 + earWiggle);
    final leftEar = Rect.fromCenter(
        center: Offset.zero, width: w * 0.095, height: h * 0.22);
    canvas.drawOval(leftEar, furPaint);
    canvas.drawOval(leftEar, outlinePaint);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(0, h * 0.01), width: w * 0.048, height: h * 0.14),
      innerEarPaint,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(centerX + w * 0.075, baseY - h * 0.20);
    canvas.rotate(0.14 - earWiggle);
    final rightEar = Rect.fromCenter(
        center: Offset.zero, width: w * 0.095, height: h * 0.22);
    canvas.drawOval(rightEar, furPaint);
    canvas.drawOval(rightEar, outlinePaint);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(0, h * 0.01), width: w * 0.048, height: h * 0.14),
      innerEarPaint,
    );
    canvas.restore();

    // Fluffy round bunny tail
    final tailCenter = Offset(centerX - w * 0.16, baseY + h * 0.18);
    canvas.drawCircle(tailCenter, w * 0.042, furPaint);
    canvas.drawCircle(tailCenter, w * 0.042, outlinePaint);

    // Chubby body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, baseY + h * 0.16),
        width: w * 0.28,
        height: h * 0.21,
      ),
      Radius.circular(w * 0.13),
    );
    canvas.drawRRect(bodyRect, furPaint);
    canvas.drawRRect(bodyRect, outlinePaint);

    // Pink belly patch
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, baseY + h * 0.175),
        width: w * 0.14,
        height: h * 0.11,
      ),
      Paint()..color = const Color(0xFFFFE2EF),
    );

    // Head
    final headRect = Rect.fromCenter(
      center: Offset(centerX, baseY - h * 0.01),
      width: w * 0.34,
      height: h * 0.27,
    );
    canvas.drawOval(headRect, furPaint);
    canvas.drawOval(headRect, outlinePaint);

    // Rosy cheeks
    final cheekPaint =
        Paint()..color = const Color(0xFFFFB2D3).withValues(alpha: 0.78);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - w * 0.10, baseY + h * 0.025),
        width: w * 0.062,
        height: h * 0.038,
      ),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + w * 0.10, baseY + h * 0.025),
        width: w * 0.062,
        height: h * 0.038,
      ),
      cheekPaint,
    );

    _drawCharacterEyes(canvas, w, h, centerX, baseY - h * 0.02);

    // Tiny pink bunny nose & mouth
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, baseY + h * 0.008),
        width: w * 0.028,
        height: h * 0.02,
      ),
      Paint()..color = const Color(0xFFFF88B7),
    );
    _drawCuteMouth(canvas, w, h, centerX, baseY + h * 0.028);

    // Paws
    canvas.drawCircle(
        Offset(centerX - w * 0.09, baseY + h * 0.145), w * 0.032, furPaint);
    canvas.drawCircle(
        Offset(centerX - w * 0.09, baseY + h * 0.145), w * 0.032, outlinePaint);
    canvas.drawCircle(
        Offset(centerX + w * 0.09, baseY + h * 0.145), w * 0.032, furPaint);
    canvas.drawCircle(
        Offset(centerX + w * 0.09, baseY + h * 0.145), w * 0.032, outlinePaint);
  }

  void _drawCat(
    Canvas canvas,
    double w,
    double h, {
    required double centerX,
    required double baseY,
    required double tailSwing,
  }) {
    final catFurPaint = Paint()..color = const Color(0xFFFFF4F9);
    final innerEarPaint = Paint()..color = const Color(0xFFB5DEFF);
    final outlinePaint = Paint()
      ..color = const Color(0xFF7D6B8E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.015
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Curled swinging cat tail on the right
    final tailPath = Path()
      ..moveTo(centerX + w * 0.12, baseY + h * 0.18)
      ..quadraticBezierTo(
        centerX + w * 0.24,
        baseY + h * (0.16 + tailSwing),
        centerX + w * 0.22,
        baseY + h * (0.06 + tailSwing),
      );
    canvas.drawPath(
      tailPath,
      Paint()
        ..color = const Color(0xFF7D6B8E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.036
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      tailPath,
      Paint()
        ..color = const Color(0xFFFFE2EF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.022
        ..strokeCap = StrokeCap.round,
    );

    // Pointed Cat Ears
    final leftCatEar = Path()
      ..moveTo(centerX - w * 0.13, baseY - h * 0.07)
      ..lineTo(centerX - w * 0.12, baseY - h * 0.21)
      ..lineTo(centerX - w * 0.03, baseY - h * 0.12)
      ..close();
    canvas.drawPath(leftCatEar, catFurPaint);
    canvas.drawPath(leftCatEar, outlinePaint);

    final leftInner = Path()
      ..moveTo(centerX - w * 0.115, baseY - h * 0.095)
      ..lineTo(centerX - w * 0.11, baseY - h * 0.175)
      ..lineTo(centerX - w * 0.055, baseY - h * 0.12)
      ..close();
    canvas.drawPath(leftInner, innerEarPaint);

    final rightCatEar = Path()
      ..moveTo(centerX + w * 0.13, baseY - h * 0.07)
      ..lineTo(centerX + w * 0.12, baseY - h * 0.21)
      ..lineTo(centerX + w * 0.03, baseY - h * 0.12)
      ..close();
    canvas.drawPath(rightCatEar, catFurPaint);
    canvas.drawPath(rightCatEar, outlinePaint);

    final rightInner = Path()
      ..moveTo(centerX + w * 0.115, baseY - h * 0.095)
      ..lineTo(centerX + w * 0.11, baseY - h * 0.175)
      ..lineTo(centerX + w * 0.055, baseY - h * 0.12)
      ..close();
    canvas.drawPath(rightInner, innerEarPaint);

    // Cat body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, baseY + h * 0.15),
        width: w * 0.26,
        height: h * 0.20,
      ),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(bodyRect, catFurPaint);
    canvas.drawRRect(bodyRect, outlinePaint);

    // Pastel blue belly patch on Cat
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, baseY + h * 0.165),
        width: w * 0.13,
        height: h * 0.10,
      ),
      Paint()..color = const Color(0xFFDDF0FF),
    );

    // Cat head
    final headRect = Rect.fromCenter(
      center: Offset(centerX, baseY - h * 0.01),
      width: w * 0.32,
      height: h * 0.25,
    );
    canvas.drawOval(headRect, catFurPaint);
    canvas.drawOval(headRect, outlinePaint);

    // Cute tiny forehead stripes
    final stripePaint = Paint()
      ..color = const Color(0xFFCBB8E8)
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(centerX, baseY - h * 0.125),
        Offset(centerX, baseY - h * 0.095), stripePaint);
    canvas.drawLine(Offset(centerX - w * 0.028, baseY - h * 0.12),
        Offset(centerX - w * 0.022, baseY - h * 0.095), stripePaint);
    canvas.drawLine(Offset(centerX + w * 0.028, baseY - h * 0.12),
        Offset(centerX + w * 0.022, baseY - h * 0.095), stripePaint);

    // Rosy cheeks
    final cheekPaint =
        Paint()..color = const Color(0xFFFFB2D3).withValues(alpha: 0.72);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - w * 0.095, baseY + h * 0.025),
        width: w * 0.058,
        height: h * 0.036,
      ),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + w * 0.095, baseY + h * 0.025),
        width: w * 0.058,
        height: h * 0.036,
      ),
      cheekPaint,
    );

    _drawCharacterEyes(canvas, w, h, centerX, baseY - h * 0.02);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, baseY + h * 0.008),
        width: w * 0.026,
        height: h * 0.018,
      ),
      Paint()..color = const Color(0xFFFF88B7),
    );
    _drawCuteMouth(canvas, w, h, centerX, baseY + h * 0.028);

    // Cat whiskers
    final whiskerPaint = Paint()
      ..color = const Color(0xFFB5A4C7)
      ..strokeWidth = w * 0.009
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(centerX - w * 0.18, baseY),
        Offset(centerX - w * 0.12, baseY + h * 0.006), whiskerPaint);
    canvas.drawLine(Offset(centerX - w * 0.185, baseY + h * 0.025),
        Offset(centerX - w * 0.12, baseY + h * 0.022), whiskerPaint);
    canvas.drawLine(Offset(centerX + w * 0.18, baseY),
        Offset(centerX + w * 0.12, baseY + h * 0.006), whiskerPaint);
    canvas.drawLine(Offset(centerX + w * 0.185, baseY + h * 0.025),
        Offset(centerX + w * 0.12, baseY + h * 0.022), whiskerPaint);

    // Paws
    canvas.drawCircle(
        Offset(centerX - w * 0.085, baseY + h * 0.138), w * 0.03, catFurPaint);
    canvas.drawCircle(
        Offset(centerX - w * 0.085, baseY + h * 0.138), w * 0.03, outlinePaint);
    canvas.drawCircle(
        Offset(centerX + w * 0.085, baseY + h * 0.138), w * 0.03, catFurPaint);
    canvas.drawCircle(
        Offset(centerX + w * 0.085, baseY + h * 0.138), w * 0.03, outlinePaint);
  }

  void _drawCharacterEyes(
    Canvas canvas,
    double w,
    double h,
    double centerX,
    double eyeY,
  ) {
    final eyePaint = Paint()..color = const Color(0xFF3E314D);
    final shinePaint = Paint()..color = Colors.white;
    final leftCenter = Offset(centerX - w * 0.068, eyeY);
    final rightCenter = Offset(centerX + w * 0.068, eyeY);

    if (category == WeatherCategory.clear && isDay) {
      // Happy ^ ^ eyes
      final happyPaint = Paint()
        ..color = const Color(0xFF3E314D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.015
        ..strokeCap = StrokeCap.round;

      final leftArc = Path()
        ..moveTo(leftCenter.dx - w * 0.024, eyeY + h * 0.008)
        ..quadraticBezierTo(leftCenter.dx, eyeY - h * 0.022,
            leftCenter.dx + w * 0.024, eyeY + h * 0.008);
      final rightArc = Path()
        ..moveTo(rightCenter.dx - w * 0.024, eyeY + h * 0.008)
        ..quadraticBezierTo(rightCenter.dx, eyeY - h * 0.022,
            rightCenter.dx + w * 0.024, eyeY + h * 0.008);
      canvas.drawPath(leftArc, happyPaint);
      canvas.drawPath(rightArc, happyPaint);
    } else if (category == WeatherCategory.clear && !isDay) {
      // Cozy sleepy closed eyes for clear night
      final sleepPaint = Paint()
        ..color = const Color(0xFF5A4B6C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.014
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(leftCenter - Offset(w * 0.02, 0),
          leftCenter + Offset(w * 0.02, 0), sleepPaint);
      canvas.drawLine(rightCenter - Offset(w * 0.02, 0),
          rightCenter + Offset(w * 0.02, 0), sleepPaint);
    } else if (category == WeatherCategory.thunderstorm) {
      // Surprised cute > < eyes for thunderstorm
      final scaredPaint = Paint()
        ..color = const Color(0xFF3E314D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.014
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(leftCenter + Offset(-w * 0.018, -h * 0.012),
          leftCenter + Offset(w * 0.012, 0), scaredPaint);
      canvas.drawLine(leftCenter + Offset(-w * 0.018, h * 0.012),
          leftCenter + Offset(w * 0.012, 0), scaredPaint);
      canvas.drawLine(rightCenter + Offset(w * 0.018, -h * 0.012),
          rightCenter + Offset(-w * 0.012, 0), scaredPaint);
      canvas.drawLine(rightCenter + Offset(w * 0.018, h * 0.012),
          rightCenter + Offset(-w * 0.012, 0), scaredPaint);
    } else {
      canvas.drawCircle(leftCenter, w * 0.022, eyePaint);
      canvas.drawCircle(rightCenter, w * 0.022, eyePaint);
      canvas.drawCircle(
          leftCenter + Offset(-w * 0.007, -w * 0.007), w * 0.008, shinePaint);
      canvas.drawCircle(
          rightCenter + Offset(-w * 0.007, -w * 0.007), w * 0.008, shinePaint);
    }
  }

  void _drawCuteMouth(
    Canvas canvas,
    double w,
    double h,
    double centerX,
    double mouthY,
  ) {
    final mouthPaint = Paint()
      ..color = const Color(0xFF6B587A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path()
      ..moveTo(centerX - w * 0.032, mouthY)
      ..quadraticBezierTo(
          centerX - w * 0.016, mouthY + h * 0.022, centerX, mouthY)
      ..quadraticBezierTo(
          centerX + w * 0.016, mouthY + h * 0.022, centerX + w * 0.032, mouthY);
    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawWeatherBackdrop(Canvas canvas, double w, double h, double phase) {
    final drift = math.sin(phase) * w * 0.02;

    if (category == WeatherCategory.clear ||
        category == WeatherCategory.partlyCloudy) {
      final sunCenter = Offset(w * 0.84, h * 0.21);
      if (isDay) {
        canvas.drawCircle(
            sunCenter, w * 0.085, Paint()..color = const Color(0xFFFFDF7A));
        final rayPaint = Paint()
          ..color = const Color(0xFFFFD15C)
          ..strokeWidth = w * 0.014
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i < 8; i++) {
          final angle = (math.pi / 4) * i + (phase * 0.25);
          final p1 = sunCenter +
              Offset(math.cos(angle) * w * 0.11, math.sin(angle) * w * 0.11);
          final p2 = sunCenter +
              Offset(math.cos(angle) * w * 0.14, math.sin(angle) * w * 0.14);
          canvas.drawLine(p1, p2, rayPaint);
        }
      } else {
        // Pastel crescent moon at night
        canvas.drawCircle(
            sunCenter, w * 0.08, Paint()..color = const Color(0xFFFFEBA8));
        canvas.drawCircle(sunCenter + Offset(w * 0.032, -h * 0.015), w * 0.068,
            Paint()..color = const Color(0xFFD6DCFF));
      }
    }

    if (category == WeatherCategory.cloudy ||
        category == WeatherCategory.partlyCloudy ||
        category == WeatherCategory.fog ||
        category == WeatherCategory.rain ||
        category == WeatherCategory.drizzle ||
        category == WeatherCategory.thunderstorm) {
      final cloudColor = category == WeatherCategory.thunderstorm
          ? const Color(0xFFC0B1E8)
          : category == WeatherCategory.rain
              ? const Color(0xFFCEE6FF)
              : const Color(0xFFE6F3FF);
      final cloudPaint = Paint()..color = cloudColor;
      canvas.drawCircle(
          Offset(w * 0.18 + drift, h * 0.22), w * 0.06, cloudPaint);
      canvas.drawCircle(
          Offset(w * 0.25 + drift, h * 0.18), w * 0.075, cloudPaint);
      canvas.drawCircle(
          Offset(w * 0.33 + drift, h * 0.22), w * 0.055, cloudPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.13 + drift, h * 0.20, w * 0.24, w * 0.08),
          Radius.circular(w * 0.04),
        ),
        cloudPaint,
      );

      // Extra cloud on the right for overcast/thunderstorm
      if (category == WeatherCategory.cloudy ||
          category == WeatherCategory.thunderstorm) {
        canvas.drawCircle(
            Offset(w * 0.72 - drift, h * 0.20), w * 0.055, cloudPaint);
        canvas.drawCircle(
            Offset(w * 0.80 - drift, h * 0.17), w * 0.068, cloudPaint);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.67 - drift, h * 0.19, w * 0.20, w * 0.07),
            Radius.circular(w * 0.035),
          ),
          cloudPaint,
        );
      }
    }
  }

  void _drawForegroundProp(Canvas canvas, double w, double h, double phase) {
    final t = transitionProgress.clamp(0.0, 1.2);

    // 1. Snow / Cloudy: cozy pastel scarves + falling snowflakes for snow
    if (category == WeatherCategory.snow || category == WeatherCategory.cloudy) {
      canvas.save();
      canvas.translate(0, (1 - t) * h * 0.06);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(w * 0.32, h * 0.75),
            width: w * 0.22,
            height: h * 0.045,
          ),
          Radius.circular(w * 0.02),
        ),
        Paint()..color = const Color(0xFFFFA9CF),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(w * 0.69, h * 0.76),
            width: w * 0.21,
            height: h * 0.045,
          ),
          Radius.circular(w * 0.02),
        ),
        Paint()..color = const Color(0xFF9ED0FF),
      );
      canvas.restore();

      if (category == WeatherCategory.snow) {
        final snowPaint = Paint()..color = Colors.white;
        for (var i = 0; i < 6; i++) {
          final fallY = ((idleProgress + i * 0.17) % 1.0) * h * 0.65 + h * 0.15;
          final x = w * (0.12 + i * 0.15);
          canvas.drawCircle(Offset(x, fallY), w * 0.016, snowPaint);
        }
      }
    }

    // 2. Fog: soft drifting mist ribbons
    if (category == WeatherCategory.fog) {
      final mistOffset = math.sin(phase) * w * 0.04;
      final mistPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.65 * t.clamp(0.0, 1.0))
        ..strokeWidth = h * 0.032
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(w * 0.12 + mistOffset, h * 0.77),
          Offset(w * 0.45 + mistOffset, h * 0.77), mistPaint);
      canvas.drawLine(Offset(w * 0.52 - mistOffset, h * 0.82),
          Offset(w * 0.88 - mistOffset, h * 0.82), mistPaint);
    }

    // 3. Drizzle: delicate small pastel mist drops + cute mini pastel leaf hat/umbrella for Bunny only
    if (category == WeatherCategory.drizzle) {
      final dropPaint = Paint()..color = const Color(0xFF9AD0FF);
      for (var i = 0; i < 4; i++) {
        final fallY = ((idleProgress + i * 0.25) % 1.0) * h * 0.45 + h * 0.28;
        final x = w * (0.14 + i * 0.24);
        canvas.drawCircle(Offset(x, fallY), w * 0.012, dropPaint);
      }

      // Cute pastel leaf umbrella held by Bunny & Cat
      canvas.save();
      canvas.translate(w * 0.50, h * 0.34);
      canvas.scale(t.clamp(0.2, 1.1));
      final stemPaint = Paint()
        ..color = const Color(0xFF7D6B8E)
        ..strokeWidth = w * 0.012
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset.zero, Offset(0, h * 0.32), stemPaint);

      final leafPath = Path()
        ..moveTo(-w * 0.22, 0)
        ..quadraticBezierTo(0, -h * 0.16, w * 0.22, 0)
        ..quadraticBezierTo(0, h * 0.04, -w * 0.22, 0);
      canvas.drawPath(leafPath, Paint()..color = const Color(0xFFA7E8C9));
      canvas.drawPath(
        leafPath,
        Paint()
          ..color = const Color(0xFF6BA68A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.012,
      );
      canvas.restore();
    }

    // 4. Rain & Thunderstorm: animated falling raindrops + big shared pastel umbrella opening smoothly
    if (category == WeatherCategory.rain ||
        category == WeatherCategory.thunderstorm) {
      final dropPaint = Paint()..color = const Color(0xFF6EB8FF);
      for (var i = 0; i < 6; i++) {
        final fallY = ((idleProgress * 1.4 + i * 0.18) % 1.0) * h * 0.55 + h * 0.25;
        final x = w * (0.09 + (i * 0.16));
        final drop = Path()
          ..moveTo(x, fallY - w * 0.02)
          ..quadraticBezierTo(x + w * 0.018, fallY + w * 0.01, x, fallY + w * 0.022)
          ..quadraticBezierTo(x - w * 0.018, fallY + w * 0.01, x, fallY - w * 0.02);
        canvas.drawPath(drop, dropPaint);
      }

      // Smoothly opening shared umbrella
      canvas.save();
      canvas.translate(w * 0.50, h * 0.31);
      canvas.scale(t.clamp(0.2, 1.12), 1.0);
      final handlePaint = Paint()
        ..color = const Color(0xFF7D6B8E)
        ..strokeWidth = w * 0.014
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, -h * 0.08), Offset(0, h * 0.42), handlePaint);

      final canopyColor = category == WeatherCategory.thunderstorm
          ? const Color(0xFFB39DDB)
          : const Color(0xFFFF9EC7);
      final canopyPath = Path()
        ..moveTo(-w * 0.34, h * 0.03)
        ..quadraticBezierTo(0, -h * 0.22, w * 0.34, h * 0.03)
        ..close();
      canvas.drawPath(canopyPath, Paint()..color = canopyColor);
      canvas.drawPath(canopyPath, handlePaint);
      canvas.restore();

      if (category == WeatherCategory.thunderstorm) {
        final flashAlpha = (math.sin(phase * 3).abs() * 0.7 + 0.3);
        final boltPaint = Paint()
          ..color = const Color(0xFFFFD54F).withValues(alpha: flashAlpha);
        final bolt = Path()
          ..moveTo(w * 0.83, h * 0.25)
          ..lineTo(w * 0.78, h * 0.34)
          ..lineTo(w * 0.82, h * 0.34)
          ..lineTo(w * 0.77, h * 0.43)
          ..lineTo(w * 0.85, h * 0.32)
          ..lineTo(w * 0.81, h * 0.32)
          ..close();
        canvas.drawPath(bolt, boltPaint);
      }
    }

    // Twinkling pastel stars
    final twinkle = 0.6 + 0.4 * math.sin(phase * 2);
    _drawStar(
      canvas,
      Offset(w * 0.12, h * 0.36),
      w * 0.022 * twinkle,
      Paint()..color = const Color(0xFFFFB5D8),
    );
    _drawStar(
      canvas,
      Offset(w * 0.88, h * 0.50),
      w * 0.02 * (1.4 - twinkle),
      Paint()..color = const Color(0xFF8CCBFF),
    );
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + r, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + r)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - r, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - r);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BunnyAndCatPainter oldDelegate) => true;
}
