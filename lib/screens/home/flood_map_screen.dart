import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/models/flood_data.dart';
import '../../core/providers/flood_data_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/status_badge.dart';
import 'flood_details_screen.dart';

class FloodMapScreen extends StatefulWidget {
  const FloodMapScreen({super.key});

  @override
  State<FloodMapScreen> createState() => _FloodMapScreenState();
}

class _FloodMapScreenState extends State<FloodMapScreen> {
  final MapController _mapController = MapController();

  // Malaysia approximate center
  final LatLng _centerMalaysia = const LatLng(4.2105, 108.9758);
  
  FloodData? _selectedStation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FloodDataProvider>();
      if (provider.floodData.isEmpty && !provider.isLoading) {
        provider.fetchFloodData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FloodDataProvider>();

    return Stack(
      children: [
        // ==========================================
        // MAP VIEW
        // ==========================================
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _centerMalaysia,
            initialZoom: 5.5,
            minZoom: 5.5, // Prevent zooming out to see the whole world
            maxZoom: 18.0,
            cameraConstraint: CameraConstraint.contain(
              bounds: LatLngBounds(
                const LatLng(0.0, 99.0), // South-West (Sumatra area)
                const LatLng(8.0, 120.0), // North-East (Sabah/Philippines border area)
              ),
            ),
            onTap: (_, _) {
              // Dismiss selected station on map tap
              if (_selectedStation != null) {
                setState(() {
                  _selectedStation = null;
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.myflood.malaysia',
            ),
            MarkerLayer(
              markers: _buildMarkers(provider.floodData),
            ),
          ],
        ),

        // ==========================================
        // UI OVERLAYS
        // ==========================================

        // Top Search / Header Area
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background,
                  AppColors.background.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Interactive Flood Map',
                    style: AppTextStyles.title,
                  ),
                  if (provider.isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
                      onPressed: () => provider.fetchFloodData(),
                      tooltip: 'Refresh Map Data',
                    ),
                ],
              ),
            ),
          ),
        ),

        // Error State
        if (provider.errorMessage != null && provider.floodData.isEmpty)
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Card(
              color: AppColors.card,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.critical),
                    const SizedBox(height: 8),
                    const Text('Failed to load map data', style: AppTextStyles.heading),
                    Text(provider.errorMessage!, style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),

        // Selected Station Bottom Sheet
        if (_selectedStation != null)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: _buildStationPopup(_selectedStation!),
          ),
      ],
    );
  }

  List<Marker> _buildMarkers(List<FloodData> data) {
    // Filter out stations with invalid or missing coordinates
    final validStations = data.where((s) => s.latitude != 0.0 && s.longitude != 0.0);

    return validStations.map((station) {
      final status = _mapApiStatusToEnum(station.waterLevelIndicator);
      final color = _statusColor(status);
      final isSelected = _selectedStation?.stationId == station.stationId;

      return Marker(
        point: LatLng(station.latitude, station.longitude),
        width: isSelected ? 40 : 30,
        height: isSelected ? 40 : 30,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedStation = station;
            });
            // Center the map on the selected marker slightly offset to accommodate the popup
            _mapController.move(LatLng(station.latitude - 0.05, station.longitude), 10.0);
          },
          child: Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: isSelected ? 3 : 2),
            ),
            child: Center(
              child: Container(
                width: isSelected ? 16 : 10,
                height: isSelected ? 16 : 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildStationPopup(FloodData station) {
    final status = _mapApiStatusToEnum(station.waterLevelIndicator);
    
    final levelText = station.waterLevelCurrent != null 
        ? 'Water Level: ${station.waterLevelCurrent}m' 
        : 'Data unavailable';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FloodDetailsScreen(floodData: station),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    station.stationName,
                    style: AppTextStyles.title.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${station.district}, ${station.state}',
                    style: AppTextStyles.bodySecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.water_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'River Basin: ${station.mainBasin}',
                    style: AppTextStyles.bodySecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  levelText,
                  style: AppTextStyles.body.copyWith(
                    color: _statusColor(status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Row(
                  children: [
                    Text('View Details', style: AppTextStyles.caption),
                    Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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
