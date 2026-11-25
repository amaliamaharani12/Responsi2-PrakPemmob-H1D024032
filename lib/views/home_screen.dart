import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/bunny_cat_mascot.dart';
import '../widgets/daily_forecast_tile.dart';
import '../widgets/pastel_glass_card.dart';
import 'search_screen.dart';

/// Home / Weather Screen displaying live weather from Open-Meteo API,
/// cute Bunny-Cat mascot, detailed metrics, and 7-day forecast.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().initialize();
    });
  }

  Future<void> _openSearchScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainBackgroundGradient,
        ),
        child: SafeArea(
          child: Consumer<WeatherViewModel>(
            builder: (context, vm, _) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      _buildTopBar(context, vm),
                      Expanded(
                        child: RefreshIndicator(
                          color: AppTheme.pastelPinkDeep,
                          backgroundColor: AppTheme.cloudWhite,
                          onRefresh: vm.fetchWeather,
                          child: _buildBody(context, vm),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WeatherViewModel vm) {
    final isFav = vm.isCurrentLocationFavorite;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 20,
                      color: Color(0xFF6B8DE3),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        vm.selectedLocation.name,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                if (vm.selectedLocation.subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 26),
                    child: Text(
                      vm.selectedLocation.subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
          _PastelIconButton(
            icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            iconColor: isFav ? const Color(0xFFE8669E) : AppTheme.textSecondary,
            tooltip: isFav ? 'Hapus dari favorit' : 'Simpan ke favorit',
            onPressed: () => vm.toggleFavorite(),
          ),
          const SizedBox(width: 8),
          _PastelIconButton(
            icon: Icons.search_rounded,
            iconColor: const Color(0xFF5D9CE6),
            tooltip: 'Cari kota',
            onPressed: _openSearchScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel vm) {
    if (vm.isLoading && vm.weather == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: const [
          SizedBox(height: 60),
          _LoadingStateCard(),
        ],
      );
    }

    if (vm.errorMessage != null && vm.weather == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 48),
          _ErrorStateCard(
            message: vm.errorMessage!,
            onRetry: vm.fetchWeather,
          ),
        ],
      );
    }

    final weather = vm.weather;
    if (weather == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 48),
          _ErrorStateCard(
            message: 'Data cuaca belum tersedia.',
            onRetry: vm.fetchWeather,
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        if (vm.favorites.isNotEmpty) _buildFavoriteChips(context, vm),
        _buildHeroWeatherCard(context, vm, weather),
        const SizedBox(height: 16),
        _buildMetricsGrid(context, weather),
        const SizedBox(height: 18),
        _buildDailyForecastSection(context, weather),
      ],
    );
  }

  Widget _buildFavoriteChips(BuildContext context, WeatherViewModel vm) {
    return Container(
      height: 42,
      margin: const EdgeInsets.only(bottom: 14),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: vm.favorites.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final loc = vm.favorites[index];
          final isSelected = loc == vm.selectedLocation;
          return GestureDetector(
            onTap: () => vm.selectLocation(loc),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.searchHeaderGradient : null,
                color: isSelected ? null : Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    size: 14,
                    color: isSelected ? Colors.white : const Color(0xFFE8669E),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    loc.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroWeatherCard(
    BuildContext context,
    WeatherViewModel vm,
    WeatherModel weather,
  ) {
    return PastelGlassCard(
      gradient: AppTheme.heroCardGradient,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: [
          if (vm.isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: LinearProgressIndicator(
                minHeight: 3,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                        color: Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        weather.conditionLabel,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${weather.temperature2m.round()}°C',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Text(
                      'Terasa ${weather.apparentTemperature.round()}°C',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary.withValues(alpha: 0.78),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Maks ${weather.todayMaxTemp.round()}°  •  Min ${weather.todayMinTemp.round()}°',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              BunnyCatMascot(
                category: weather.category,
                isDay: weather.isDay,
                size: 145,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: Color(0xFFE07BAE),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    weather.bunnyMoodMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, WeatherModel weather) {
    final metrics = [
      _MetricItem(
        icon: Icons.water_drop_rounded,
        label: 'Kelembapan',
        value: '${weather.relativeHumidity2m}%',
        accent: const Color(0xFF5B9EE8),
      ),
      _MetricItem(
        icon: Icons.air_rounded,
        label: 'Kecepatan Angin',
        value: '${weather.windSpeed10m.toStringAsFixed(1)} km/j',
        accent: const Color(0xFF837AE0),
      ),
      _MetricItem(
        icon: Icons.umbrella_rounded,
        label: 'Peluang Hujan',
        value: '${weather.todayRainProbability}%',
        accent: const Color(0xFFE07BAE),
      ),
      _MetricItem(
        icon: Icons.grain_rounded,
        label: 'Curah Hujan',
        value: '${weather.precipitation.toStringAsFixed(1)} mm',
        accent: const Color(0xFF4CA7D9),
      ),
      _MetricItem(
        icon: Icons.thermostat_rounded,
        label: 'Suhu Terasa',
        value: '${weather.apparentTemperature.toStringAsFixed(1)}°C',
        accent: const Color(0xFFEA849F),
      ),
      _MetricItem(
        icon: Icons.tag_rounded,
        label: 'Kode Cuaca',
        value: 'WMO ${weather.weatherCode}',
        accent: const Color(0xFF7D78C9),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.15,
      ),
      itemBuilder: (context, index) {
        final item = metrics[index];
        return PastelGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                          ),
                    ),
                    Text(
                      item.value,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyForecastSection(
    BuildContext context,
    WeatherModel weather,
  ) {
    return PastelGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: Color(0xFF6B8DE3),
              ),
              const SizedBox(width: 8),
              Text(
                'Perkiraan Beberapa Hari Ke Depan',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(weather.dailyForecasts.length, (index) {
            return DailyForecastTile(
              forecast: weather.dailyForecasts[index],
              isToday: index == 0,
            );
          }),
        ],
      ),
    );
  }
}

class _MetricItem {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });
}

class _PastelIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String tooltip;
  final VoidCallback onPressed;

  const _PastelIconButton({
    required this.icon,
    required this.iconColor,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.8),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }
}

class _LoadingStateCard extends StatelessWidget {
  const _LoadingStateCard();

  @override
  Widget build(BuildContext context) {
    return PastelGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Column(
        children: [
          const BunnyCatMascot(
            category: WeatherCategory.partlyCloudy,
            size: 130,
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(
            color: AppTheme.pastelPinkDeep,
          ),
          const SizedBox(height: 14),
          Text(
            'Sedang mengambil data cuaca...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _ErrorStateCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorStateCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return PastelGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 22),
      child: Column(
        children: [
          const BunnyCatMascot(
            category: WeatherCategory.rain,
            size: 130,
          ),
          const SizedBox(height: 14),
          Text(
            'Ups, cuaca belum bisa dimuat',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6BAEEB),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
