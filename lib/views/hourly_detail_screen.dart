import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../widgets/bunny_cat_mascot.dart';
import '../widgets/daily_forecast_tile.dart';
import '../widgets/pastel_glass_card.dart';
import '../widgets/weather_icon_widget.dart';

/// Detail screen showing 24-hour weather breakdown for any selected date
/// (yesterday, today, or upcoming days) with a pinned Bunny & Cat hero card.
class HourlyDetailScreen extends StatefulWidget {
  final String cityName;
  final DailyForecastModel forecast;
  final List<HourlyForecastModel> hourlyForecasts;
  final bool isFahrenheit;

  const HourlyDetailScreen({
    super.key,
    required this.cityName,
    required this.forecast,
    required this.hourlyForecasts,
    this.isFahrenheit = false,
  });

  @override
  State<HourlyDetailScreen> createState() => _HourlyDetailScreenState();
}

class _HourlyDetailScreenState extends State<HourlyDetailScreen> {
  int _selectedHourIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.hourlyForecasts.isNotEmpty) {
      final now = DateTime.now();
      final isToday = widget.forecast.date.year == now.year &&
          widget.forecast.date.month == now.month &&
          widget.forecast.date.day == now.day;

      if (isToday) {
        final idx =
            widget.hourlyForecasts.indexWhere((h) => h.time.hour == now.hour);
        _selectedHourIndex = idx >= 0 ? idx : 0;
      } else {
        final idx =
            widget.hourlyForecasts.indexWhere((h) => h.time.hour == 12);
        _selectedHourIndex = idx >= 0 ? idx : 0;
      }
    }
  }

  String _formatTemp(double celsius) {
    final val = widget.isFahrenheit ? (celsius * 9 / 5) + 32 : celsius;
    final unit = widget.isFahrenheit ? '°F' : '°C';
    return '${val.round()}$unit';
  }

  @override
  Widget build(BuildContext context) {
    final dayTitle = DailyForecastTile.formatDayLabel(widget.forecast.date);
    final dateFormatted = DateFormat('d MMMM yyyy').format(widget.forecast.date);
    final activeHour = widget.hourlyForecasts.isNotEmpty
        ? widget.hourlyForecasts[_selectedHourIndex]
        : null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainBackgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, dayTitle, dateFormatted),
                  // Pinned hero card so Bunny & Cat stay visible while scrolling hours
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                    child: _buildHeroDuoCard(context, activeHour),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                    child: Text(
                      'Detail Cuaca Per Jam (Ketuk jam untuk lihat animasi)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14.5,
                          ),
                    ),
                  ),
                  Expanded(
                    child: widget.hourlyForecasts.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: PastelGlassCard(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'Data per jam belum tersedia untuk tanggal ini.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                            itemCount: widget.hourlyForecasts.length,
                            itemBuilder: (context, i) {
                              final item = widget.hourlyForecasts[i];
                              return _HourlyRowTile(
                                hourly: item,
                                isSelected: i == _selectedHourIndex,
                                formattedTemp: _formatTemp(item.temperature2m),
                                onTap: () {
                                  setState(() {
                                    _selectedHourIndex = i;
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String dayTitle,
    String dateFormatted,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 18, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: AppTheme.textPrimary,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.cityName} • $dayTitle',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  dateFormatted,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroDuoCard(
    BuildContext context,
    HourlyForecastModel? activeHour,
  ) {
    final category = activeHour?.category ?? widget.forecast.category;
    final isDay = activeHour?.isDay ?? true;
    final condition =
        activeHour?.conditionLabel ?? widget.forecast.conditionLabel;
    final tempText = activeHour != null
        ? _formatTemp(activeHour.temperature2m)
        : _formatTemp(widget.forecast.temperatureMax);
    final timeLabel = activeHour != null
        ? 'Pukul ${DateFormat('HH:mm').format(activeHour.time)}'
        : 'Ringkasan Harian';

    return PastelGlassCard(
      gradient: AppTheme.heroCardGradient,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        timeLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tempText,
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(fontSize: 48),
                    ),
                    Text(
                      condition,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Maks ${_formatTemp(widget.forecast.temperatureMax)} • Min ${_formatTemp(widget.forecast.temperatureMin)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              BunnyCatMascot(
                category: category,
                isDay: isDay,
                size: 138,
              ),
            ],
          ),
          if (activeHour != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _MiniStatChip(
                  icon: Icons.water_drop_rounded,
                  label: 'Lembap ${activeHour.relativeHumidity2m}%',
                  color: const Color(0xFF569BE8),
                ),
                const SizedBox(width: 8),
                _MiniStatChip(
                  icon: Icons.umbrella_rounded,
                  label: 'Hujan ${activeHour.precipitationProbability}%',
                  color: const Color(0xFFE07BAE),
                ),
                const SizedBox(width: 8),
                _MiniStatChip(
                  icon: Icons.air_rounded,
                  label: '${activeHour.windSpeed10m.toStringAsFixed(0)} km/j',
                  color: const Color(0xFF837AE0),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniStatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13.5, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HourlyRowTile extends StatelessWidget {
  final HourlyForecastModel hourly;
  final bool isSelected;
  final String formattedTemp;
  final VoidCallback onTap;

  const _HourlyRowTile({
    required this.hourly,
    required this.isSelected,
    required this.formattedTemp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(hourly.time);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.heroCardGradient : null,
              color: isSelected ? null : Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? AppTheme.pastelPinkDeep
                    : Colors.white.withValues(alpha: 0.9),
                width: isSelected ? 1.8 : 1.2,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  child: Text(
                    timeStr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14.5,
                        ),
                  ),
                ),
                WeatherIconWidget(category: hourly.category, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hourly.conditionLabel,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 14,
                            ),
                      ),
                      Text(
                        'Kelembapan ${hourly.relativeHumidity2m}% • Angin ${hourly.windSpeed10m.toStringAsFixed(0)} km/j',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 11.5,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.pastelBlueLight.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${hourly.precipitationProbability}%',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4778B5),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  formattedTemp,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
