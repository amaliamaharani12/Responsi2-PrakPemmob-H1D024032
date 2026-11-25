import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/bunny_cat_mascot.dart';
import '../widgets/daily_forecast_tile.dart';
import '../widgets/pastel_glass_card.dart';
import 'hourly_detail_screen.dart';
import 'search_screen.dart';

/// Home / Weather Screen displaying live weather from Open-Meteo API,
/// animated Bunny & Cat duo mascot, expandable metric details,
/// activity tips, and daily forecast (yesterday, today, upcoming days).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _expandedMetricIndex;

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
          Tooltip(
            message: 'Ubah satuan suhu',
            child: Material(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: vm.toggleTemperatureUnit,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  child: Text(
                    vm.tempUnit,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5D9CE6),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
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
        _buildMetricsSection(context, vm, weather),
        const SizedBox(height: 16),
        _buildActivityTipCard(context, weather),
        const SizedBox(height: 16),
        _buildDailyForecastSection(context, vm, weather),
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
                      vm.formatTemp(weather.temperature2m),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Text(
                      'Terasa ${vm.formatTemp(weather.apparentTemperature)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary.withValues(alpha: 0.78),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Maks ${vm.formatTemp(weather.todayMaxTemp)}  •  Min ${vm.formatTemp(weather.todayMinTemp)}',
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

  List<_MetricItem> _buildMetricItems(
    WeatherViewModel vm,
    WeatherModel weather,
  ) {
    final humidityStatus = weather.relativeHumidity2m >= 80
        ? 'Cukup Lembap'
        : weather.relativeHumidity2m >= 55
            ? 'Nyaman'
            : 'Udara Kering';
    final windStatus = weather.windSpeed10m >= 25
        ? 'Angin Kencang'
        : weather.windSpeed10m >= 12
            ? 'Angin Sedang'
            : 'Angin Sepoi';
    final rainStatus = weather.todayRainProbability >= 60
        ? 'Potensi Tinggi'
        : weather.todayRainProbability >= 30
            ? 'Bisa Turun Hujan'
            : 'Cenderung Aman';

    return [
      _MetricItem(
        icon: Icons.water_drop_rounded,
        label: 'Kelembapan',
        value: '${weather.relativeHumidity2m}%',
        accent: const Color(0xFF5B9EE8),
        statusBadge: humidityStatus,
        description:
            'Kelembapan udara saat ini ${weather.relativeHumidity2m}%. Nilai 50%-75% umumnya terasa paling nyaman untuk aktivitas di luar ruangan.',
      ),
      _MetricItem(
        icon: Icons.air_rounded,
        label: 'Kecepatan Angin',
        value: '${weather.windSpeed10m.toStringAsFixed(1)} km/j',
        accent: const Color(0xFF837AE0),
        statusBadge: windStatus,
        description:
            'Kecepatan angin di ketinggian 10 meter tercatat ${weather.windSpeed10m.toStringAsFixed(1)} km/jam. Tetap waspada jika berkendara saat angin bertiup kencang.',
      ),
      _MetricItem(
        icon: Icons.umbrella_rounded,
        label: 'Peluang Hujan',
        value: '${weather.todayRainProbability}%',
        accent: const Color(0xFFE07BAE),
        statusBadge: rainStatus,
        description:
            'Kemungkinan hujan maksimum hari ini mencapai ${weather.todayRainProbability}%. Jika di atas 50%, sebaiknya siapkan payung atau jas hujan.',
      ),
      _MetricItem(
        icon: Icons.grain_rounded,
        label: 'Curah Hujan',
        value: '${weather.precipitation.toStringAsFixed(1)} mm',
        accent: const Color(0xFF4CA7D9),
        statusBadge:
            weather.precipitation > 0 ? 'Sedang Basah' : 'Tidak Ada Hujan',
        description:
            'Curah hujan terkini adalah ${weather.precipitation.toStringAsFixed(1)} mm (total hujan/gerimis yang turun saat pengukuran terakhir).',
      ),
      _MetricItem(
        icon: Icons.thermostat_rounded,
        label: 'Suhu Terasa',
        value: vm.formatTemp(weather.apparentTemperature, decimals: 1),
        accent: const Color(0xFFEA849F),
        statusBadge:
            weather.apparentTemperature > weather.temperature2m
                ? 'Terasa Lebih Hangat'
                : 'Terasa Sejuk',
        description:
            'Suhu yang dirasakan tubuh (${vm.formatTemp(weather.apparentTemperature, decimals: 1)}) dipengaruhi oleh suhu udara, kelembapan, dan hembusan angin.',
      ),
      _MetricItem(
        icon: Icons.tag_rounded,
        label: 'Kode Cuaca',
        value: 'WMO ${weather.weatherCode}',
        accent: const Color(0xFF7D78C9),
        statusBadge: weather.conditionLabel,
        description:
            'Kode WMO ${weather.weatherCode} adalah standar internasional World Meteorological Organization yang diartikan sebagai "${weather.conditionLabel}".',
      ),
    ];
  }

  Widget _buildMetricsSection(
    BuildContext context,
    WeatherViewModel vm,
    WeatherModel weather,
  ) {
    final metrics = _buildMetricItems(vm, weather);
    final rowCount = (metrics.length / 2).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Ketuk kartu untuk melihat penjelasan detail',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                ),
          ),
        ),
        ...List.generate(rowCount, (rowIndex) {
          final leftIndex = rowIndex * 2;
          final rightIndex = leftIndex + 1;
          final hasRight = rightIndex < metrics.length;
          final isRowExpanded = _expandedMetricIndex == leftIndex ||
              (hasRight && _expandedMetricIndex == rightIndex);

          return Padding(
            padding: EdgeInsets.only(bottom: rowIndex < rowCount - 1 ? 10 : 0),
            child: Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          metrics[leftIndex],
                          leftIndex,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: hasRight
                            ? _buildMetricCard(
                                context,
                                metrics[rightIndex],
                                rightIndex,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOut,
                  child: isRowExpanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: _buildMetricDropdownDetail(
                            context,
                            metrics[_expandedMetricIndex!],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    _MetricItem item,
    int index,
  ) {
    final isSelected = _expandedMetricIndex == index;

    return PastelGlassCard(
      onTap: () {
        setState(() {
          _expandedMetricIndex = isSelected ? null : index;
        });
      },
      gradient: isSelected
          ? LinearGradient(
              colors: [
                AppTheme.pastelBlueLight.withValues(alpha: 0.92),
                AppTheme.pastelPinkLight.withValues(alpha: 0.92),
              ],
            )
          : null,
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 11,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: item.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(item.icon, color: item.accent, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.label,
                  maxLines: 2,
                  softWrap: true,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 11.5, height: 1.2),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 14.5),
                ),
              ],
            ),
          ),
          Icon(
            isSelected
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 17,
            color: AppTheme.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricDropdownDetail(
    BuildContext context,
    _MetricItem item,
  ) {
    return PastelGlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.92),
          AppTheme.pastelPinkLight.withValues(alpha: 0.55),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, color: item.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.label}: ${item.value}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.statusBadge,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: item.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTipCard(BuildContext context, WeatherModel weather) {
    String outfitTip;
    String activityTip;

    if (weather.category == WeatherCategory.rain ||
        weather.category == WeatherCategory.thunderstorm ||
        weather.todayRainProbability >= 60) {
      outfitTip = 'Bawa payung atau jas hujan & gunakan alas kaki anti air.';
      activityTip = 'Cocok untuk aktivitas santai di dalam ruangan.';
    } else if (weather.temperature2m >= 30) {
      outfitTip = 'Gunakan pakaian katun yang sejuk & bawa air minum.';
      activityTip = 'Hindari terik matahari langsung di siang hari.';
    } else if (weather.temperature2m <= 21 ||
        weather.category == WeatherCategory.snow) {
      outfitTip = 'Pakai jaket atau sweater hangat agar tetap nyaman.';
      activityTip = 'Minuman hangat akan terasa pas untuk cuaca ini.';
    } else {
      outfitTip = 'Pakaian kasual yang ringan sudah sangat nyaman.';
      activityTip = 'Cuaca bersahabat untuk jalan sore atau olahraga ringan.';
    }

    return PastelGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppTheme.searchHeaderGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.checkroom_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saran Outfit & Aktivitas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '$outfitTip $activityTip',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecastSection(
    BuildContext context,
    WeatherViewModel vm,
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
              Expanded(
                child: Text(
                  'Perkiraan Harian (Kemarin & Ke Depan)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Ketuk tanggal untuk melihat detail cuaca per jam',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 12),
          ...List.generate(weather.dailyForecasts.length, (index) {
            final forecast = weather.dailyForecasts[index];
            return DailyForecastTile(
              forecast: forecast,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HourlyDetailScreen(
                      cityName: vm.selectedLocation.name,
                      forecast: forecast,
                      hourlyForecasts: weather.hourlyForDate(forecast.date),
                      isFahrenheit: vm.isFahrenheit,
                    ),
                  ),
                );
              },
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
  final String statusBadge;
  final String description;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.statusBadge,
    required this.description,
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
