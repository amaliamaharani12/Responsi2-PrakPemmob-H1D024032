/// Weather condition categories mapped from Open-Meteo WMO weather codes.
enum WeatherCategory {
  clear,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rain,
  snow,
  thunderstorm,
}

/// Model representing current weather, daily forecast, and hourly forecast from Open-Meteo API.
class WeatherModel {
  final double temperature2m;
  final int relativeHumidity2m;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed10m;
  final bool isDay;
  final String timezone;
  final List<DailyForecastModel> dailyForecasts;
  final List<HourlyForecastModel> hourlyForecasts;

  const WeatherModel({
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
    required this.isDay,
    required this.timezone,
    required this.dailyForecasts,
    this.hourlyForecasts = const [],
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final daily = json['daily'] as Map<String, dynamic>? ?? {};
    final hourly = json['hourly'] as Map<String, dynamic>? ?? {};

    final dates = (daily['time'] as List<dynamic>? ?? []).cast<String>();
    final codes = (daily['weather_code'] as List<dynamic>? ?? [])
        .map((e) => (e as num).toInt())
        .toList();
    final maxTemps = (daily['temperature_2m_max'] as List<dynamic>? ?? [])
        .map((e) => (e as num).toDouble())
        .toList();
    final minTemps = (daily['temperature_2m_min'] as List<dynamic>? ?? [])
        .map((e) => (e as num).toDouble())
        .toList();
    final rainProbs =
        (daily['precipitation_probability_max'] as List<dynamic>? ?? [])
            .map((e) => (e as num?)?.toInt() ?? 0)
            .toList();

    final forecasts = <DailyForecastModel>[];
    for (var i = 0; i < dates.length; i++) {
      forecasts.add(
        DailyForecastModel(
          date: DateTime.parse(dates[i]),
          weatherCode: i < codes.length ? codes[i] : 0,
          temperatureMax: i < maxTemps.length ? maxTemps[i] : 0.0,
          temperatureMin: i < minTemps.length ? minTemps[i] : 0.0,
          precipitationProbabilityMax:
              i < rainProbs.length ? rainProbs[i] : 0,
        ),
      );
    }

    final hourlyTimes = (hourly['time'] as List<dynamic>? ?? []).cast<String>();
    final hourlyTemps = (hourly['temperature_2m'] as List<dynamic>? ?? [])
        .map((e) => (e as num?)?.toDouble() ?? 0.0)
        .toList();
    final hourlyHumidity =
        (hourly['relative_humidity_2m'] as List<dynamic>? ?? [])
            .map((e) => (e as num?)?.toInt() ?? 0)
            .toList();
    final hourlyRainProb =
        (hourly['precipitation_probability'] as List<dynamic>? ?? [])
            .map((e) => (e as num?)?.toInt() ?? 0)
            .toList();
    final hourlyCodes = (hourly['weather_code'] as List<dynamic>? ?? [])
        .map((e) => (e as num?)?.toInt() ?? 0)
        .toList();
    final hourlyWinds = (hourly['wind_speed_10m'] as List<dynamic>? ?? [])
        .map((e) => (e as num?)?.toDouble() ?? 0.0)
        .toList();
    final hourlyIsDay = (hourly['is_day'] as List<dynamic>? ?? [])
        .map((e) => ((e as num?)?.toInt() ?? 1) == 1)
        .toList();

    final hourlyList = <HourlyForecastModel>[];
    for (var i = 0; i < hourlyTimes.length; i++) {
      hourlyList.add(
        HourlyForecastModel(
          time: DateTime.parse(hourlyTimes[i]),
          temperature2m: i < hourlyTemps.length ? hourlyTemps[i] : 0.0,
          relativeHumidity2m: i < hourlyHumidity.length ? hourlyHumidity[i] : 0,
          precipitationProbability:
              i < hourlyRainProb.length ? hourlyRainProb[i] : 0,
          weatherCode: i < hourlyCodes.length ? hourlyCodes[i] : 0,
          windSpeed10m: i < hourlyWinds.length ? hourlyWinds[i] : 0.0,
          isDay: i < hourlyIsDay.length ? hourlyIsDay[i] : true,
        ),
      );
    }

    return WeatherModel(
      temperature2m: (current['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity2m:
          (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature:
          (current['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (current['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed10m: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      isDay: ((current['is_day'] as num?)?.toInt() ?? 1) == 1,
      timezone: json['timezone'] as String? ?? 'auto',
      dailyForecasts: forecasts,
      hourlyForecasts: hourlyList,
    );
  }

  /// Returns today's forecast (matching current date, or falling back to first entry).
  DailyForecastModel? get todayForecast {
    if (dailyForecasts.isEmpty) return null;
    final now = DateTime.now();
    for (final item in dailyForecasts) {
      if (item.date.year == now.year &&
          item.date.month == now.month &&
          item.date.day == now.day) {
        return item;
      }
    }
    return dailyForecasts.length > 1 ? dailyForecasts[1] : dailyForecasts.first;
  }

  /// Filters hourly entries belonging to [date].
  List<HourlyForecastModel> hourlyForDate(DateTime date) {
    return hourlyForecasts
        .where((h) =>
            h.time.year == date.year &&
            h.time.month == date.month &&
            h.time.day == date.day)
        .toList();
  }

  int get todayRainProbability =>
      todayForecast?.precipitationProbabilityMax ?? 0;

  double get todayMaxTemp => todayForecast?.temperatureMax ?? temperature2m;

  double get todayMinTemp => todayForecast?.temperatureMin ?? temperature2m;

  WeatherCategory get category => categoryFromCode(weatherCode);

  String get conditionLabel => labelFromCode(weatherCode);

  String get bunnyMoodMessage => moodMessageFromCategory(category, isDay);

  static WeatherCategory categoryFromCode(int code) {
    if (code == 0) return WeatherCategory.clear;
    if (code == 1 || code == 2) return WeatherCategory.partlyCloudy;
    if (code == 3) return WeatherCategory.cloudy;
    if (code == 45 || code == 48) return WeatherCategory.fog;
    if (code >= 51 && code <= 57) return WeatherCategory.drizzle;
    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return WeatherCategory.rain;
    }
    if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
      return WeatherCategory.snow;
    }
    if (code >= 95 && code <= 99) return WeatherCategory.thunderstorm;
    return WeatherCategory.partlyCloudy;
  }

  static String labelFromCode(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Cerah Berawan';
      case 2:
        return 'Berawan Sebagian';
      case 3:
        return 'Mendung';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
      case 53:
      case 55:
        return 'Gerimis';
      case 56:
      case 57:
        return 'Gerimis Dingin';
      case 61:
        return 'Hujan Ringan';
      case 63:
        return 'Hujan Sedang';
      case 65:
        return 'Hujan Lebat';
      case 66:
      case 67:
        return 'Hujan Es';
      case 71:
      case 73:
      case 75:
      case 77:
        return 'Salju';
      case 80:
      case 81:
      case 82:
        return 'Hujan Lokal';
      case 85:
      case 86:
        return 'Hujan Salju';
      case 95:
        return 'Badai Petir';
      case 96:
      case 99:
        return 'Badai Petir & Es';
      default:
        return 'Berawan';
    }
  }

  static String moodMessageFromCategory(WeatherCategory category, bool isDay) {
    switch (category) {
      case WeatherCategory.clear:
        return isDay
            ? 'Langit cerah sekali, Bunny dan Cat siap jalan santai!'
            : 'Malam cerah berbintang, Bunny dan Cat siap istirahat.';
      case WeatherCategory.partlyCloudy:
        return 'Awan lembut menemani langit hari ini.';
      case WeatherCategory.cloudy:
        return 'Langit teduh berawan, tetap semangat ya!';
      case WeatherCategory.fog:
        return 'Udara berkabut, hati-hati di perjalanan.';
      case WeatherCategory.drizzle:
        return 'Gerimis manja turun, Bunny dan Cat berbagi payung.';
      case WeatherCategory.rain:
        return 'Sedang hujan, jangan lupa bawa payung ya!';
      case WeatherCategory.snow:
        return 'Udara dingin bersalju, pakai syal hangat!';
      case WeatherCategory.thunderstorm:
        return 'Ada badai petir, lebih aman di dalam ruangan.';
    }
  }
}

/// Daily weather forecast entry from Open-Meteo `daily` array.
class DailyForecastModel {
  final DateTime date;
  final int weatherCode;
  final double temperatureMax;
  final double temperatureMin;
  final int precipitationProbabilityMax;

  const DailyForecastModel({
    required this.date,
    required this.weatherCode,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbabilityMax,
  });

  WeatherCategory get category => WeatherModel.categoryFromCode(weatherCode);

  String get conditionLabel => WeatherModel.labelFromCode(weatherCode);
}

/// Hourly weather forecast entry from Open-Meteo `hourly` array.
class HourlyForecastModel {
  final DateTime time;
  final double temperature2m;
  final int relativeHumidity2m;
  final int precipitationProbability;
  final int weatherCode;
  final double windSpeed10m;
  final bool isDay;

  const HourlyForecastModel({
    required this.time,
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.precipitationProbability,
    required this.weatherCode,
    required this.windSpeed10m,
    required this.isDay,
  });

  WeatherCategory get category => WeatherModel.categoryFromCode(weatherCode);

  String get conditionLabel => WeatherModel.labelFromCode(weatherCode);
}
