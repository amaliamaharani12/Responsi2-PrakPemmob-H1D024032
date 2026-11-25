import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pastel_sky_weather/main.dart';
import 'package:pastel_sky_weather/models/location_model.dart';
import 'package:pastel_sky_weather/models/weather_model.dart';
import 'package:pastel_sky_weather/services/weather_api_service.dart';
import 'package:pastel_sky_weather/widgets/bunny_cat_mascot.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('WeatherModel parses Open-Meteo JSON response accurately', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final sampleJson = {
      'timezone': 'Asia/Jakarta',
      'current': {
        'temperature_2m': 28.4,
        'relative_humidity_2m': 74,
        'apparent_temperature': 31.2,
        'precipitation': 0.5,
        'weather_code': 61,
        'wind_speed_10m': 11.8,
        'is_day': 1,
      },
      'daily': {
        'time': [fmt(yesterday), fmt(today)],
        'weather_code': [2, 61],
        'temperature_2m_max': [31.0, 30.1],
        'temperature_2m_min': [22.8, 23.4],
        'precipitation_probability_max': [35, 80],
      },
      'hourly': {
        'time': ['${fmt(yesterday)}T09:00', '${fmt(today)}T12:00', '${fmt(today)}T15:00'],
        'temperature_2m': [27.0, 29.5, 28.0],
        'relative_humidity_2m': [78, 70, 72],
        'precipitation_probability': [20, 80, 60],
        'weather_code': [2, 61, 61],
        'wind_speed_10m': [10.0, 12.0, 8.5],
        'is_day': [1, 1, 1],
      },
    };

    final weather = WeatherModel.fromJson(sampleJson);

    expect(weather.temperature2m, 28.4);
    expect(weather.relativeHumidity2m, 74);
    expect(weather.apparentTemperature, 31.2);
    expect(weather.precipitation, 0.5);
    expect(weather.weatherCode, 61);
    expect(weather.windSpeed10m, 11.8);
    expect(weather.category, WeatherCategory.rain);
    expect(weather.conditionLabel, 'Hujan Ringan');
    expect(weather.dailyForecasts.length, 2);
    expect(weather.hourlyForecasts.length, 3);
    expect(weather.hourlyForDate(today).length, 2);
    expect(weather.todayRainProbability, 80);
  });

  test('WeatherApiService fetches and parses geocoding & weather via GET',
      () async {
    final mockClient = MockClient((request) async {
      expect(request.method, 'GET');
      if (request.url.host.contains('geocoding-api')) {
        return http.Response(
          jsonEncode({
            'results': [
              {
                'id': 1650357,
                'name': 'Bandung',
                'latitude': -6.9222,
                'longitude': 107.6069,
                'country': 'Indonesia',
                'admin1': 'Jawa Barat',
              },
            ],
          }),
          200,
        );
      }

      return http.Response(
        jsonEncode({
          'timezone': 'Asia/Jakarta',
          'current': {
            'temperature_2m': 24.5,
            'relative_humidity_2m': 80,
            'apparent_temperature': 26.0,
            'precipitation': 0.0,
            'weather_code': 0,
            'wind_speed_10m': 8.2,
            'is_day': 1,
          },
          'daily': {
            'time': ['2026-11-25'],
            'weather_code': [0],
            'temperature_2m_max': [28.0],
            'temperature_2m_min': [19.5],
            'precipitation_probability_max': [10],
          },
        }),
        200,
      );
    });

    final service = WeatherApiService(client: mockClient);
    final locations = await service.searchLocations('Bandung');
    expect(locations.length, 1);
    expect(locations.first.name, 'Bandung');

    final weather = await service.fetchWeather(
      latitude: locations.first.latitude,
      longitude: locations.first.longitude,
    );
    expect(weather.temperature2m, 24.5);
    expect(weather.category, WeatherCategory.clear);
  });

  testWidgets('PastelSkyWeatherApp renders HomeScreen with BunnyCatMascot',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const PastelSkyWeatherApp());
    await tester.pump();

    expect(find.text(LocationModel.defaultLocation().name), findsOneWidget);
    expect(find.byType(BunnyCatMascot), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  });
}
