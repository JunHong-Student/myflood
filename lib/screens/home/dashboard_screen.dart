import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/flood_data_provider.dart';
import '../../core/models/flood_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_badge.dart';
import 'flood_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onTabSwitch;
  const DashboardScreen({super.key, this.onTabSwitch});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FloodDataProvider>();
      if (provider.floodData.isEmpty) {
        provider.fetchFloodData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FloodDataProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // PAGE HEADER
          // ==========================================

          const Text(
            'National Flood Situation Overview',
            style: AppTextStyles.title,
          ),

          const SizedBox(height: 6),

          const Text(
            'Current flood situation across Malaysia',
            style: AppTextStyles.bodySecondary,
          ),

          const SizedBox(height: 8),

          const Row(
            children: [
              Icon(
                Icons.access_time,
                size: 12,
                color: AppColors.textSecondary,
              ),

              SizedBox(width: 5),

              Text(
                'Live Government Telemetry Data',
                style: AppTextStyles.caption,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ==========================================
          // DYNAMIC CONTENT
          // ==========================================
          
          if (provider.isLoading && provider.floodData.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (provider.errorMessage != null && provider.floodData.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.critical, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load data',
                      style: AppTextStyles.heading,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage!,
                      style: AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchFloodData(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // ==========================================
            // SUMMARY CARDS
            // ==========================================

            _buildSummaryGrid(provider.floodData),

            const SizedBox(height: 24),

            // ==========================================
            // ACTIVE FLOOD EVENTS
            // ==========================================

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Flood Events',
                  style: AppTextStyles.heading,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
                  onPressed: () => provider.fetchFloodData(),
                  tooltip: 'Refresh Data',
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildActiveFloodEvents(provider.floodData),

            const SizedBox(height: 24),
          ],

          // ==========================================
          // QUICK ACTIONS
          // ==========================================

          const Text(
            'Quick Actions',
            style: AppTextStyles.heading,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.search,
                  title: 'Search Records',
                  onTap: () => widget.onTabSwitch?.call(1),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildQuickAction(
                  icon: Icons.map_outlined,
                  title: 'Flood Map',
                  onTap: () => widget.onTabSwitch?.call(3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.bar_chart_outlined,
                  title: 'Statistics',
                  onTap: () => widget.onTabSwitch?.call(4),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildQuickAction(
                  icon: Icons.phone_outlined,
                  title: 'Emergency',
                  onTap: () => widget.onTabSwitch?.call(5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SUMMARY GRID
  // ==========================================

  Widget _buildSummaryGrid(List<FloodData> data) {
    int dangerCount = 0;
    int warningCount = 0;
    int alertCount = 0;

    for (var station in data) {
      if (station.waterLevelIndicator == 'DANGER') {
        dangerCount++;
      } else if (station.waterLevelIndicator == 'WARNING') {
        warningCount++;
      } else if (station.waterLevelIndicator == 'ALERT') {
        alertCount++;
      }
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.7,
      children: [
        _buildSummaryCard(
          title: 'Critical Alerts',
          value: dangerCount.toString(),
          color: AppColors.critical,
          icon: Icons.warning_rounded,
        ),

        _buildSummaryCard(
          title: 'Warnings',
          value: warningCount.toString(),
          color: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        ),

        _buildSummaryCard(
          title: 'Advisories',
          value: alertCount.toString(),
          color: AppColors.advisory,
          icon: Icons.info_outline,
        ),

        _buildSummaryCard(
          title: 'Total Stations', // Replaced "People Affected"
          value: data.length.toString(),
          color: AppColors.primaryBlue,
          icon: Icons.sensors,
        ),
      ],
    );
  }

  // ==========================================
  // SUMMARY CARD
  // ==========================================

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 18,
              ),

              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              Text(
                title,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ACTIVE FLOOD EVENTS
  // ==========================================

  Widget _buildActiveFloodEvents(List<FloodData> data) {
    // Filter to only show events that are not NORMAL and have a valid indicator
    final activeEvents = data.where((station) {
      final ind = station.waterLevelIndicator;
      return ind != null && ind != 'NORMAL' && ind != 'NO_RAINFALL';
    }).toList();

    if (activeEvents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Text(
            'No active flood events reported at this time.',
            style: AppTextStyles.bodySecondary,
          ),
        ),
      );
    }

    // Sort by severity (DANGER first)
    activeEvents.sort((a, b) {
      int score(String? ind) {
        if (ind == 'DANGER') return 3;
        if (ind == 'WARNING') return 2;
        if (ind == 'ALERT') return 1;
        return 0;
      }
      return score(b.waterLevelIndicator).compareTo(score(a.waterLevelIndicator));
    });

    // Take top 5 for the dashboard to avoid massive list
    final displayEvents = activeEvents.take(5).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayEvents.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final event = displayEvents[index];
        final status = _mapApiStatusToEnum(event.waterLevelIndicator);
        
        final levelText = event.waterLevelCurrent != null 
            ? 'Water Level: ${event.waterLevelCurrent}m' 
            : 'Data unavailable';
            
        return _buildFloodEvent(
          location: '${event.stationName}, ${event.district}',
          river: event.mainBasin,
          status: status,
          affected: levelText, // Replaced "people affected"
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FloodDetailsScreen(floodData: event),
              ),
            );
          },
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

  Widget _buildFloodEvent({
    required String location,
    required String river,
    required FloodStatus status,
    required String affected,
    required VoidCallback onTap,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
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
                  location,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  river,
                  style: AppTextStyles.bodySecondary,
                ),

                const SizedBox(height: 5),

                Text(
                  affected,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          StatusBadge(
            status: status,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // QUICK ACTION
  // ==========================================

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 18,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body,
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textSecondary,
            size: 12,
          ),
        ],
      ),
    );
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