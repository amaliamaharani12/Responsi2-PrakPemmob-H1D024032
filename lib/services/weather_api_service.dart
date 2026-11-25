import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_model.dart';

/// Custom exception for Open-Meteo API errors.
class WeatherApiException implements Exception {
  final String message;

  const WeatherApiException(this.message);

  @override
  String toString() => message;
}

/// Service handling HTTP GET requests to Open-Meteo Forecast & Geocoding APIs.
class WeatherApiService {
  static const String _forecastBaseUrl =
      'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  final http.Client _client;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches current weather and 7-day forecast for [latitude] and [longitude].
  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_forecastBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,is_day',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'timezone': 'auto',
      },
    );

    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw WeatherApiException(
          'Gagal memuat data cuaca (Status ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (decoded['current'] == null) {
        throw const WeatherApiException('Data cuaca tidak tersedia.');
      }

      return WeatherModel.fromJson(decoded);
    } on WeatherApiException {
      rethrow;
    } catch (e) {
      throw const WeatherApiException(
        'Tidak dapat terhubung ke server cuaca. Periksa koneksi internetmu.',
      );
    }
  }

  /// Searches cities by [query] using Open-Meteo Geocoding API.
  Future<List<LocationModel>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return [];
    }

    final uri = Uri.parse(_geocodingBaseUrl).replace(
      queryParameters: {
        'name': trimmed,
        'count': '15',
        'language': 'en',
        'format': 'json',
      },
    );

    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw WeatherApiException(
          'Gagal mencari lokasi (Status ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final results = decoded['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) {
        return [];
      }

      return results
          .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on WeatherApiException {
      rethrow;
    } catch (e) {
      throw const WeatherApiException(
        'Gagal mencari kota. Periksa koneksi internetmu.',
      );
    }
  }
}
