import 'package:flutter/material.dart';
import '../models/weather_model.dart';

/// Custom-drawn pastel weather icon widget (zero keyboard emojis).
class WeatherIconWidget extends StatelessWidget {
  final WeatherCategory category;
  final double size;

  const WeatherIconWidget({
    super.key,
    required this.category,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 10,
      height: size + 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientFor(category),
        ),
      ),
      child: Icon(
        _iconFor(category),
        size: size * 0.65,
        color: _iconColorFor(category),
      ),
    );
  }

  IconData _iconFor(WeatherCategory category) {
    switch (category) {
      case WeatherCategory.clear:
        return Icons.wb_sunny_rounded;
      case WeatherCategory.partlyCloudy:
        return Icons.wb_cloudy_rounded;
      case WeatherCategory.cloudy:
        return Icons.cloud_rounded;
      case WeatherCategory.fog:
        return Icons.blur_on_rounded;
      case WeatherCategory.drizzle:
        return Icons.grain_rounded;
      case WeatherCategory.rain:
        return Icons.umbrella_rounded;
      case WeatherCategory.snow:
        return Icons.ac_unit_rounded;
      case WeatherCategory.thunderstorm:
        return Icons.thunderstorm_rounded;
    }
  }

  List<Color> _gradientFor(WeatherCategory category) {
    switch (category) {
      case WeatherCategory.clear:
        return const [Color(0xFFFFF0B8), Color(0xFFFFD1DC)];
      case WeatherCategory.partlyCloudy:
        return const [Color(0xFFD6ECFF), Color(0xFFFFDCEB)];
      case WeatherCategory.cloudy:
      case WeatherCategory.fog:
        return const [Color(0xFFDDE8FF), Color(0xFFECE2FF)];
      case WeatherCategory.drizzle:
      case WeatherCategory.rain:
        return const [Color(0xFFBBE1FF), Color(0xFFFFD2E8)];
      case WeatherCategory.snow:
        return const [Color(0xFFE5F4FF), Color(0xFFFDE6F2)];
      case WeatherCategory.thunderstorm:
        return const [Color(0xFFCBBFFF), Color(0xFFFFBFE0)];
    }
  }

  Color _iconColorFor(WeatherCategory category) {
    switch (category) {
      case WeatherCategory.clear:
        return const Color(0xFFE08D3C);
      case WeatherCategory.partlyCloudy:
        return const Color(0xFF5D9CE6);
      case WeatherCategory.cloudy:
      case WeatherCategory.fog:
        return const Color(0xFF7B89B8);
      case WeatherCategory.drizzle:
      case WeatherCategory.rain:
        return const Color(0xFF4C8EE0);
      case WeatherCategory.snow:
        return const Color(0xFF6BAEEB);
      case WeatherCategory.thunderstorm:
        return const Color(0xFF7857B8);
    }
  }
}
