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
        'time': ['2026-11-25', '2026-11-26'],
        'weather_code': [61, 2],
        'temperature_2m_max': [30.1, 31.0],
        'temperature_2m_min': [23.4, 22.8],
        'precipitation_probability_max': [80, 35],
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
