import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import 'weather_icon_widget.dart';

/// Single row for daily weather forecast on the Home / Weather Screen.
class DailyForecastTile extends StatelessWidget {
  final DailyForecastModel forecast;
  final bool isToday;

  const DailyForecastTile({
    super.key,
    required this.forecast,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabel =
        isToday ? 'Hari Ini' : DateFormat('EEE, d MMM').format(forecast.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: isToday
            ? LinearGradient(
                colors: [
                  AppTheme.pastelBlueLight.withValues(alpha: 0.85),
                  AppTheme.pastelPinkLight.withValues(alpha: 0.85),
                ],
              )
            : null,
        color: isToday ? null : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          WeatherIconWidget(category: forecast.category, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14.5,
                      ),
                ),
                Text(
                  forecast.conditionLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12.5,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.pastelBlueLight.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.water_drop_rounded,
                  size: 13,
                  color: Color(0xFF569BE8),
                ),
                const SizedBox(width: 3),
                Text(
                  '${forecast.precipitationProbabilityMax}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4778B5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${forecast.temperatureMax.round()}° / ${forecast.temperatureMin.round()}°',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 14.5,
                  color: AppTheme.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}
