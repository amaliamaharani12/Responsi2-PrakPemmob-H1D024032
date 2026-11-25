import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/weather_model.dart';

/// Cute pastel Bunny-Cat ("Usagi-Neko") mascot illustration drawn with CustomPainter
/// that adapts to the current weather condition without using any keyboard emojis.
class BunnyCatMascot extends StatelessWidget {
  final WeatherCategory category;
  final bool isDay;
  final double size;

  const BunnyCatMascot({
    super.key,
    required this.category,
    this.isDay = true,
    this.size = 156,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BunnyCatPainter(
          category: category,
          isDay: isDay,
        ),
      ),
    );
  }
}

class _BunnyCatPainter extends CustomPainter {
  final WeatherCategory category;
  final bool isDay;

  _BunnyCatPainter({
    required this.category,
    required this.isDay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.58);

    // Soft pastel aura behind mascot
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.72),
          const Color(0xFFFFD8EA).withValues(alpha: 0.35),
          const Color(0xFFCDE9FF).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.48));
    canvas.drawCircle(center, w * 0.48, auraPaint);

    _drawWeatherBackdrop(canvas, w, h);
    _drawBunnyEars(canvas, w, h);

    // Chubby little body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.76),
        width: w * 0.40,
        height: h * 0.28,
      ),
      Radius.circular(w * 0.18),
    );
    final furPaint = Paint()..color = const Color(0xFFFFFCFE);
    final outlinePaint = Paint()
      ..color = const Color(0xFF7D6B8E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawRRect(bodyRect, furPaint);
    canvas.drawRRect(bodyRect, outlinePaint);

    // Pastel pink belly patch
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.78),
        width: w * 0.20,
        height: h * 0.15,
      ),
      Paint()..color = const Color(0xFFFFE2EF),
    );

    // Cute Bunny-Cat Head
    final headCenter = Offset(w * 0.5, h * 0.54);
    final headRect = Rect.fromCenter(
      center: headCenter,
      width: w * 0.48,
      height: h * 0.36,
    );
    canvas.drawOval(headRect, furPaint);
    canvas.drawOval(headRect, outlinePaint);

    // Rosy pastel pink cheeks
    final cheekPaint =
        Paint()..color = const Color(0xFFFFB2D3).withValues(alpha: 0.75);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.34, h * 0.58),
        width: w * 0.09,
        height: h * 0.055,
      ),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.66, h * 0.58),
        width: w * 0.09,
        height: h * 0.055,
      ),
      cheekPaint,
    );

    _drawEyes(canvas, w, h);

    // Tiny pink cat nose + 'w' mouth
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.555),
        width: w * 0.036,
        height: h * 0.024,
      ),
      Paint()..color = const Color(0xFFFF88B7),
    );

    final mouthPaint = Paint()
      ..color = const Color(0xFF6B587A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.014
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path()
      ..moveTo(w * 0.455, h * 0.585)
      ..quadraticBezierTo(w * 0.478, h * 0.612, w * 0.50, h * 0.585)
      ..quadraticBezierTo(w * 0.522, h * 0.612, w * 0.545, h * 0.585);
    canvas.drawPath(mouthPath, mouthPaint);

    // Cat whiskers
    final whiskerPaint = Paint()
      ..color = const Color(0xFFB5A4C7)
      ..strokeWidth = w * 0.011
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(w * 0.27, h * 0.54), Offset(w * 0.34, h * 0.55), whiskerPaint);
    canvas.drawLine(
        Offset(w * 0.26, h * 0.575), Offset(w * 0.34, h * 0.572), whiskerPaint);
    canvas.drawLine(
        Offset(w * 0.73, h * 0.54), Offset(w * 0.66, h * 0.55), whiskerPaint);
    canvas.drawLine(
        Offset(w * 0.74, h * 0.575), Offset(w * 0.66, h * 0.572), whiskerPaint);

    // Little paws
    final leftPaw = Offset(w * 0.36, h * 0.74);
    final rightPaw = Offset(w * 0.64, h * 0.74);
    canvas.drawCircle(leftPaw, w * 0.048, furPaint);
    canvas.drawCircle(leftPaw, w * 0.048, outlinePaint);
    canvas.drawCircle(rightPaw, w * 0.048, furPaint);
    canvas.drawCircle(rightPaw, w * 0.048, outlinePaint);

    _drawForegroundProp(canvas, w, h);
  }

  void _drawBunnyEars(Canvas canvas, double w, double h) {
    final furPaint = Paint()..color = const Color(0xFFFFFCFE);
    final innerEarPaint = Paint()..color = const Color(0xFFFFC1DF);
    final outlinePaint = Paint()
      ..color = const Color(0xFF7D6B8E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018;

    // Left ear
    canvas.save();
    canvas.translate(w * 0.38, h * 0.32);
    canvas.rotate(-0.18);
    final leftEar = Rect.fromCenter(
        center: Offset.zero, width: w * 0.13, height: h * 0.27);
    canvas.drawOval(leftEar, furPaint);
    canvas.drawOval(leftEar, outlinePaint);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(0, h * 0.01), width: w * 0.068, height: h * 0.17),
      innerEarPaint,
    );
    canvas.restore();

    // Right ear
    canvas.save();
    canvas.translate(w * 0.62, h * 0.32);
    canvas.rotate(0.18);
    final rightEar = Rect.fromCenter(
        center: Offset.zero, width: w * 0.13, height: h * 0.27);
    canvas.drawOval(rightEar, furPaint);
    canvas.drawOval(rightEar, outlinePaint);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(0, h * 0.01), width: w * 0.068, height: h * 0.17),
      innerEarPaint,
    );
    canvas.restore();
  }

  void _drawEyes(Canvas canvas, double w, double h) {
    final eyePaint = Paint()..color = const Color(0xFF3E314D);
    final shinePaint = Paint()..color = Colors.white;

    final leftCenter = Offset(w * 0.40, h * 0.52);
    final rightCenter = Offset(w * 0.60, h * 0.52);

    if (category == WeatherCategory.clear && isDay) {
      final happyPaint = Paint()
        ..color = const Color(0xFF3E314D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.018
        ..strokeCap = StrokeCap.round;

      final leftArc = Path()
        ..moveTo(w * 0.365, h * 0.53)
        ..quadraticBezierTo(w * 0.40, h * 0.485, w * 0.435, h * 0.53);
      final rightArc = Path()
        ..moveTo(w * 0.565, h * 0.53)
        ..quadraticBezierTo(w * 0.60, h * 0.485, w * 0.635, h * 0.53);
      canvas.drawPath(leftArc, happyPaint);
      canvas.drawPath(rightArc, happyPaint);
    } else {
      canvas.drawCircle(leftCenter, w * 0.032, eyePaint);
      canvas.drawCircle(rightCenter, w * 0.032, eyePaint);
      canvas.drawCircle(
          leftCenter + Offset(-w * 0.01, -w * 0.01), w * 0.011, shinePaint);
      canvas.drawCircle(
          rightCenter + Offset(-w * 0.01, -w * 0.01), w * 0.011, shinePaint);
    }
  }

  void _drawWeatherBackdrop(Canvas canvas, double w, double h) {
    if (category == WeatherCategory.clear ||
        category == WeatherCategory.partlyCloudy) {
      final sunCenter = Offset(w * 0.80, h * 0.24);
      final sunColor =
          isDay ? const Color(0xFFFFDF7A) : const Color(0xFFFFEBA8);
      canvas.drawCircle(sunCenter, w * 0.095, Paint()..color = sunColor);

      if (isDay) {
        final rayPaint = Paint()
          ..color = const Color(0xFFFFD15C)
          ..strokeWidth = w * 0.016
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i < 8; i++) {
          final angle = (math.pi / 4) * i;
          final p1 = sunCenter +
              Offset(math.cos(angle) * w * 0.125, math.sin(angle) * w * 0.125);
          final p2 = sunCenter +
              Offset(math.cos(angle) * w * 0.155, math.sin(angle) * w * 0.155);
          canvas.drawLine(p1, p2, rayPaint);
        }
      }
    }

    if (category == WeatherCategory.cloudy ||
        category == WeatherCategory.partlyCloudy ||
        category == WeatherCategory.fog ||
        category == WeatherCategory.rain ||
        category == WeatherCategory.drizzle ||
        category == WeatherCategory.thunderstorm) {
      final cloudColor = category == WeatherCategory.thunderstorm
          ? const Color(0xFFC5B9E8)
          : const Color(0xFFE3F2FF);
      final cloudPaint = Paint()..color = cloudColor;
      canvas.drawCircle(Offset(w * 0.20, h * 0.26), w * 0.07, cloudPaint);
      canvas.drawCircle(Offset(w * 0.28, h * 0.22), w * 0.085, cloudPaint);
      canvas.drawCircle(Offset(w * 0.36, h * 0.26), w * 0.065, cloudPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.15, h * 0.24, w * 0.26, w * 0.09),
          Radius.circular(w * 0.05),
        ),
        cloudPaint,
      );
    }
  }

  void _drawForegroundProp(Canvas canvas, double w, double h) {
    if (category == WeatherCategory.snow ||
        category == WeatherCategory.cloudy ||
        category == WeatherCategory.fog) {
      final scarfPaint = Paint()..color = const Color(0xFFFFA9CF);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.70),
            width: w * 0.34,
            height: h * 0.065,
          ),
          Radius.circular(w * 0.03),
        ),
        scarfPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.55, h * 0.70, w * 0.08, h * 0.13),
          Radius.circular(w * 0.03),
        ),
        Paint()..color = const Color(0xFF9ED0FF),
      );
    }

    if (category == WeatherCategory.rain ||
        category == WeatherCategory.drizzle ||
        category == WeatherCategory.thunderstorm) {
      final dropPaint = Paint()..color = const Color(0xFF7AC0FF);
      for (final pos in [
        Offset(w * 0.14, h * 0.45),
        Offset(w * 0.85, h * 0.42),
        Offset(w * 0.18, h * 0.65),
        Offset(w * 0.82, h * 0.63),
      ]) {
        final drop = Path()
          ..moveTo(pos.dx, pos.dy - w * 0.025)
          ..quadraticBezierTo(
              pos.dx + w * 0.025, pos.dy + w * 0.01, pos.dx, pos.dy + w * 0.028)
          ..quadraticBezierTo(pos.dx - w * 0.025, pos.dy + w * 0.01, pos.dx,
              pos.dy - w * 0.025);
        canvas.drawPath(drop, dropPaint);
      }

      final handlePaint = Paint()
        ..color = const Color(0xFF7D6B8E)
        ..strokeWidth = w * 0.014
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
          Offset(w * 0.73, h * 0.42), Offset(w * 0.66, h * 0.73), handlePaint);

      final canopyPath = Path()
        ..moveTo(w * 0.61, h * 0.42)
        ..quadraticBezierTo(w * 0.75, h * 0.28, w * 0.87, h * 0.46)
        ..close();
      canvas.drawPath(canopyPath, Paint()..color = const Color(0xFFFF9EC7));
      canvas.drawPath(canopyPath, handlePaint);
    }

    final sparklePaint = Paint()..color = const Color(0xFFFFB5D8);
    _drawStar(canvas, Offset(w * 0.19, h * 0.40), w * 0.025, sparklePaint);
    _drawStar(canvas, Offset(w * 0.83, h * 0.54), w * 0.022,
        Paint()..color = const Color(0xFF8CCBFF));
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
  bool shouldRepaint(covariant _BunnyCatPainter oldDelegate) =>
      oldDelegate.category != category || oldDelegate.isDay != isDay;
}
