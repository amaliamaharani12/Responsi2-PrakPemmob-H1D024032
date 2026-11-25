import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

/// ViewModel for the Search / Location Screen (MVVM).
/// Handles city search via Open-Meteo Geocoding API and search history persistence.
class SearchViewModel extends ChangeNotifier {
  final WeatherApiService _apiService;
  final LocalStorageService _storageService;

  SearchViewModel({
    WeatherApiService? apiService,
    LocalStorageService? storageService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _storageService = storageService ?? LocalStorageService();

  List<LocationModel> _searchResults = [];
  List<LocationModel> _searchHistory = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _errorMessage;
  String _lastQuery = '';

  List<LocationModel> get searchResults => List.unmodifiable(_searchResults);
  List<LocationModel> get searchHistory => List.unmodifiable(_searchHistory);
  bool get isSearching => _isSearching;
  bool get hasSearched => _hasSearched;
  String? get errorMessage => _errorMessage;
  String get lastQuery => _lastQuery;

  /// Loads persisted search history when Search Screen opens.
  Future<void> loadHistory() async {
    _searchHistory = await _storageService.getSearchHistory();
    notifyListeners();
  }

  /// Queries Open-Meteo Geocoding API for [query].
  Future<void> searchCities(String query) async {
    final trimmed = query.trim();
    _lastQuery = trimmed;

    if (trimmed.isEmpty) {
      _searchResults = [];
      _hasSearched = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _hasSearched = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchLocations(trimmed);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Saves a chosen city to Local Storage search history.
  Future<void> recordSelection(LocationModel location) async {
    _searchHistory = await _storageService.addToSearchHistory(location);
    notifyListeners();
  }

  /// Clears all saved search history.
  Future<void> clearHistory() async {
    await _storageService.clearSearchHistory();
    _searchHistory = [];
    notifyListeners();
  }

  void clearSearchState() {
    _searchResults = [];
    _hasSearched = false;
    _errorMessage = null;
    _lastQuery = '';
    notifyListeners();
  }
}
