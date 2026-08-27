import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/favorites_provider.dart';
import '../../core/providers/flood_data_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_badge.dart';
import 'flood_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final floodProvider = context.read<FloodDataProvider>();
      if (floodProvider.floodData.isEmpty && !floodProvider.isLoading) {
        floodProvider.fetchFloodData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final floodProvider = context.watch<FloodDataProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saved Stations',
                style: AppTextStyles.title,
              ),
              if (favoritesProvider.favoriteIds.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _showClearConfirmation(context, favoritesProvider),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.critical,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: _buildFavoritesList(floodProvider, favoritesProvider),
        ),
      ],
    );
  }

  Widget _buildFavoritesList(FloodDataProvider floodProvider, FavoritesProvider favProvider) {
    if (floodProvider.isLoading && floodProvider.floodData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (floodProvider.errorMessage != null && floodProvider.floodData.isEmpty) {
      return Center(
        child: Text(
          'Failed to load records.\n${floodProvider.errorMessage}',
          style: AppTextStyles.bodySecondary,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (favProvider.favoriteIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'No favorites yet',
              style: AppTextStyles.heading,
            ),
            const SizedBox(height: 8),
            Text(
              'Save your important stations here.',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      );
    }

    final favoriteStations = floodProvider.floodData
        .where((station) => favProvider.isFavorite(station.stationId))
        .toList();
        
    if (favoriteStations.isEmpty && floodProvider.floodData.isNotEmpty) {
       return Center(
        child: Text(
          'Saved stations not found in current data.',
          style: AppTextStyles.bodySecondary,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: favoriteStations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final station = favoriteStations[index];
        final status = _mapApiStatusToEnum(station.waterLevelIndicator);
        
        final levelText = station.waterLevelCurrent != null 
            ? 'Water Level: ${station.waterLevelCurrent}m' 
            : 'Data unavailable';

        return AppCard(
          padding: const EdgeInsets.all(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FloodDetailsScreen(floodData: station),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                width: 4,
                height: 58,
                decoration: BoxDecoration(
                  color: _statusColor(status),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${station.stationName}, ${station.district}',
                      style: AppTextStyles.heading.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      station.mainBasin,
                      style: AppTextStyles.bodySecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      levelText,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: status),
            ],
          ),
        );
      },
    );
  }

  FloodStatus _mapApiStatusToEnum(String? apiIndicator) {
    switch (apiIndicator) {
      case 'DANGER':
        return FloodStatus.critical;
      case 'WARNING':
        return FloodStatus.warning;
      case 'ALERT':
        return FloodStatus.advisory;
      default:
        return FloodStatus.normal;
    }
  }

  Color _statusColor(FloodStatus status) {
    switch (status) {
      case FloodStatus.normal:
        return AppColors.normal;
      case FloodStatus.advisory:
        return AppColors.advisory;
      case FloodStatus.warning:
        return AppColors.warning;
      case FloodStatus.critical:
        return AppColors.critical;
    }
  }

  void _showClearConfirmation(BuildContext context, FavoritesProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove all saved stations?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.clearAll();
                Navigator.of(context).pop();
              },
              child: const Text('Clear', style: TextStyle(color: AppColors.critical)),
            ),
          ],
        );
      },
    );
  }
}
