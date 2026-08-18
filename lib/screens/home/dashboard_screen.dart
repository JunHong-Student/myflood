import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_badge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                'Last updated: Today, 10:30 AM',
                style: AppTextStyles.caption,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ==========================================
          // SUMMARY CARDS
          // ==========================================

          _buildSummaryGrid(),

          const SizedBox(height: 24),

          // ==========================================
          // ACTIVE FLOOD EVENTS
          // ==========================================

          const Text(
            'Active Flood Events',
            style: AppTextStyles.heading,
          ),

          const SizedBox(height: 12),

          _buildFloodEvent(
            location: 'Kuala Lumpur',
            river: 'Sungai Klang',
            status: FloodStatus.critical,
            affected: '1,240 people affected',
          ),

          const SizedBox(height: 10),

          _buildFloodEvent(
            location: 'Kota Bharu, Kelantan',
            river: 'Sungai Kelantan',
            status: FloodStatus.warning,
            affected: '860 people affected',
          ),

          const SizedBox(height: 10),

          _buildFloodEvent(
            location: 'Kuantan, Pahang',
            river: 'Sungai Pahang',
            status: FloodStatus.advisory,
            affected: '320 people affected',
          ),

          const SizedBox(height: 24),

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
                  onTap: () {},
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildQuickAction(
                  icon: Icons.map_outlined,
                  title: 'Flood Map',
                  onTap: () {},
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
                  onTap: () {},
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildQuickAction(
                  icon: Icons.phone_outlined,
                  title: 'Emergency',
                  onTap: () {},
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

  Widget _buildSummaryGrid() {
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
          value: '1',
          color: AppColors.critical,
          icon: Icons.warning_rounded,
        ),

        _buildSummaryCard(
          title: 'Warnings',
          value: '2',
          color: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        ),

        _buildSummaryCard(
          title: 'Advisories',
          value: '2',
          color: AppColors.advisory,
          icon: Icons.info_outline,
        ),

        _buildSummaryCard(
          title: 'People Affected',
          value: '34,200',
          color: AppColors.primaryBlue,
          icon: Icons.people_outline,
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
  // FLOOD EVENT CARD
  // ==========================================

  Widget _buildFloodEvent({
    required String location,
    required String river,
    required FloodStatus status,
    required String affected,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () {
        // Later: Navigate to Flood Details
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