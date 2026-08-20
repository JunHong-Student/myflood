import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/flood_data.dart';
import '../../core/providers/favorites_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_badge.dart';

class FloodDetailsScreen extends StatelessWidget {
  final FloodData floodData;

  const FloodDetailsScreen({
    super.key,
    required this.floodData,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(floodData.stationId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Flood Event Details',
          style: AppTextStyles.title,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.critical : AppColors.textPrimary,
            ),
            onPressed: () {
              favoritesProvider.toggleFavorite(floodData.stationId);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // HEADER CARD
            // ==========================================
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          floodData.stationName,
                          style: AppTextStyles.title,
                        ),
                      ),
                      StatusBadge(
                        status: _mapApiStatusToEnum(floodData.waterLevelIndicator),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.location_on_outlined, '${floodData.district}, ${floodData.state}'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.water_outlined, 'River Basin: ${floodData.mainBasin}'),
                  if (floodData.subBasin.isNotEmpty && floodData.subBasin != floodData.mainBasin) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.subdirectory_arrow_right, 'Sub Basin: ${floodData.subBasin}'),
                  ],
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.map_outlined, 'Coordinates: ${floodData.latitude}, ${floodData.longitude}'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.sensors, 'Station Type: ${floodData.stationType}'),
                  if (floodData.waterLevelUpdateDatetime != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.access_time, 'Last Updated: ${floodData.waterLevelUpdateDatetime}'),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==========================================
            // WATER LEVEL THRESHOLDS
            // ==========================================
            const Text(
              'Water Level Status',
              style: AppTextStyles.heading,
            ),
            const SizedBox(height: 12),

            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Current Level', style: AppTextStyles.body),
                      Text(
                        floodData.waterLevelCurrent != null 
                            ? '${floodData.waterLevelCurrent} m' 
                            : 'N/A',
                        style: AppTextStyles.title.copyWith(
                          color: _statusColor(_mapApiStatusToEnum(floodData.waterLevelIndicator)),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppColors.border),
                  ),
                  _buildThresholdRow('Normal Level', floodData.waterLevelNormalLevel, AppColors.normal),
                  const SizedBox(height: 8),
                  _buildThresholdRow('Alert Level', floodData.waterLevelAlertLevel, AppColors.advisory),
                  const SizedBox(height: 8),
                  _buildThresholdRow('Warning Level', floodData.waterLevelWarningLevel, AppColors.warning),
                  const SizedBox(height: 8),
                  _buildThresholdRow('Danger Level', floodData.waterLevelDangerLevel, AppColors.critical),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildThresholdRow(String label, double? value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.bodySecondary),
          ],
        ),
        Text(
          value != null && value > 0 ? '$value m' : 'N/A',
          style: AppTextStyles.body,
        ),
      ],
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
}
