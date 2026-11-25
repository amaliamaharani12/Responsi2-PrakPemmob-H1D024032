import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

/// ViewModel for the Home / Weather Screen (MVVM).
/// Manages current weather state, selected location, favorites, and loading/error states.
class WeatherViewModel extends ChangeNotifier {
  final WeatherApiService _apiService;
  final LocalStorageService _storageService;

  WeatherViewModel({
    WeatherApiService? apiService,
    LocalStorageService? storageService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _storageService = storageService ?? LocalStorageService();

  LocationModel _selectedLocation = LocationModel.defaultLocation();
  WeatherModel? _weather;
  List<LocationModel> _favorites = [];
  bool _isLoading = false;
  String? _errorMessage;

  LocationModel get selectedLocation => _selectedLocation;
  WeatherModel? get weather => _weather;
  List<LocationModel> get favorites => List.unmodifiable(_favorites);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isCurrentLocationFavorite =>
      _favorites.contains(_selectedLocation);

  /// Initializes the ViewModel by restoring persisted location & favorites
  /// from Local Storage, then fetching live weather from Open-Meteo.
  Future<void> initialize() async {
    _favorites = await _storageService.getFavoriteLocations();
    final saved = await _storageService.getSelectedLocation();
    if (saved != null) {
      _selectedLocation = saved;
    } else if (_favorites.isNotEmpty) {
      _selectedLocation = _favorites.first;
    }
    notifyListeners();
    await fetchWeather();
  }

  /// Fetches weather data for [_selectedLocation] from Open-Meteo API.
  Future<void> fetchWeather() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.fetchWeather(
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
      );
      _weather = result;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the active location, persists it, and loads its weather.
  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    await _storageService.saveSelectedLocation(location);
    notifyListeners();
    await fetchWeather();
  }

  /// Toggles favorite status of [location] (defaults to [_selectedLocation])
  /// and persists the updated list to Local Storage.
  Future<void> toggleFavorite([LocationModel? location]) async {
    final target = location ?? _selectedLocation;
    if (_favorites.contains(target)) {
      _favorites = _favorites.where((item) => item != target).toList();
    } else {
      _favorites = [target, ..._favorites];
    }
    await _storageService.saveFavoriteLocations(_favorites);
    notifyListeners();
  }

  bool isFavorite(LocationModel location) => _favorites.contains(location);
}
