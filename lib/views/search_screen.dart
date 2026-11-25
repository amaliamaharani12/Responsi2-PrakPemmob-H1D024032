import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/bunny_cat_mascot.dart';
import '../widgets/pastel_glass_card.dart';

/// Search / Location Screen for searching cities via Open-Meteo Geocoding API,
/// viewing search history, and managing favorite locations.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchVm = context.read<SearchViewModel>();
      searchVm.clearSearchState();
      searchVm.loadHistory();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectLocation(LocationModel location) async {
    final weatherVm = context.read<WeatherViewModel>();
    final searchVm = context.read<SearchViewModel>();

    await searchVm.recordSelection(location);
    await weatherVm.selectLocation(location);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                children: [
                  _buildHeader(context),
                  _buildSearchBar(context),
                  Expanded(
                    child: Consumer2<SearchViewModel, WeatherViewModel>(
                      builder: (context, searchVm, weatherVm, _) {
                        if (searchVm.isSearching) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.pastelPinkDeep,
                            ),
                          );
                        }

                        if (searchVm.errorMessage != null) {
                          return _buildError(context, searchVm);
                        }

                        if (searchVm.hasSearched) {
                          return _buildSearchResults(
                            context,
                            searchVm,
                            weatherVm,
                          );
                        }

                        return _buildSavedSections(
                          context,
                          searchVm,
                          weatherVm,
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 18, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: AppTheme.textPrimary,
          ),
          Expanded(
            child: Text(
              'Cari Lokasi & Favorit',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                context.read<SearchViewModel>().searchCities(value);
              },
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Ketik nama kota (mis. Bandung, Tokyo)...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF6BAEEB),
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: AppTheme.textMuted,
                        onPressed: () {
                          _controller.clear();
                          context.read<SearchViewModel>().clearSearchState();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              context.read<SearchViewModel>().searchCities(_controller.text);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF08BB8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Cari',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, SearchViewModel searchVm) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PastelGlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const BunnyCatMascot(
                category: WeatherCategory.rain,
                size: 110,
              ),
              const SizedBox(height: 12),
              Text(
                searchVm.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () => searchVm.searchCities(searchVm.lastQuery),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6BAEEB),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    SearchViewModel searchVm,
    WeatherViewModel weatherVm,
  ) {
    if (searchVm.searchResults.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PastelGlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const BunnyCatMascot(
                  category: WeatherCategory.cloudy,
                  size: 110,
                ),
                const SizedBox(height: 12),
                Text(
                  'Kota "${searchVm.lastQuery}" tidak ditemukan',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Coba periksa ejaan nama kota atau gunakan nama kota lain.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      itemCount: searchVm.searchResults.length,
      itemBuilder: (context, index) {
        final location = searchVm.searchResults[index];
        return _LocationTile(
          location: location,
          isFavorite: weatherVm.isFavorite(location),
          isSelected: location == weatherVm.selectedLocation,
          onTap: () => _selectLocation(location),
          onToggleFavorite: () => weatherVm.toggleFavorite(location),
        );
      },
    );
  }

  Widget _buildSavedSections(
    BuildContext context,
    SearchViewModel searchVm,
    WeatherViewModel weatherVm,
  ) {
    final favorites = weatherVm.favorites;
    final history = searchVm.searchHistory;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
      children: [
        _SectionTitle(
          icon: Icons.favorite_rounded,
          iconColor: const Color(0xFFE8669E),
          title: 'Lokasi Favorit',
        ),
        const SizedBox(height: 10),
        if (favorites.isEmpty)
          PastelGlassCard(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Belum ada kota favorit. Tekan ikon hati pada kota untuk menyimpannya.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          ...favorites.map(
            (loc) => _LocationTile(
              location: loc,
              isFavorite: true,
              isSelected: loc == weatherVm.selectedLocation,
              onTap: () => _selectLocation(loc),
              onToggleFavorite: () => weatherVm.toggleFavorite(loc),
            ),
          ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionTitle(
              icon: Icons.history_rounded,
              iconColor: Color(0xFF5D9CE6),
              title: 'Riwayat Pencarian',
            ),
            if (history.isNotEmpty)
              TextButton(
                onPressed: searchVm.clearHistory,
                child: const Text(
                  'Hapus Semua',
                  style: TextStyle(
                    color: Color(0xFFE07BAE),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (history.isEmpty)
          PastelGlassCard(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Riwayat pencarian masih kosong. Cari kota di atas untuk melihat cuacanya.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          ...history.map(
            (loc) => _LocationTile(
              location: loc,
              isFavorite: weatherVm.isFavorite(loc),
              isSelected: loc == weatherVm.selectedLocation,
              onTap: () => _selectLocation(loc),
              onToggleFavorite: () => weatherVm.toggleFavorite(loc),
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _LocationTile extends StatelessWidget {
  final LocationModel location;
  final bool isFavorite;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _LocationTile({
    required this.location,
    required this.isFavorite,
    required this.isSelected,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PastelGlassCard(
        onTap: onTap,
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  AppTheme.pastelBlueLight.withValues(alpha: 0.9),
                  AppTheme.pastelPinkLight.withValues(alpha: 0.9),
                ],
              )
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.searchHeaderGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.location_city_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (location.subtitle.isNotEmpty)
                    Text(
                      location.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onToggleFavorite,
              tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite
                    ? const Color(0xFFE8669E)
                    : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
