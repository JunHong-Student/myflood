import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/flood_data_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_badge.dart';
import 'flood_details_screen.dart';

class FloodRecordsScreen extends StatefulWidget {
  const FloodRecordsScreen({super.key});

  @override
  State<FloodRecordsScreen> createState() => _FloodRecordsScreenState();
}

class _FloodRecordsScreenState extends State<FloodRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'ALL';

  final List<String> _statusFilters = ['ALL', 'DANGER', 'ALERT', 'NORMAL'];

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FloodDataProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          // ==========================================
        // HEADER & SEARCH BAR
        // ==========================================
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Flood Records',
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 16),
              
              // Search Input
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search station, district, state, river...',
                  hintStyle: AppTextStyles.bodySecondary,
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.card,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
                style: AppTextStyles.body,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              
              const SizedBox(height: 12),
              
              // Status Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _statusFilters.map((filter) {
                    final isSelected = _selectedStatusFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedStatusFilter = filter;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryBlue : AppColors.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryBlue : AppColors.border,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // ==========================================
        // RECORDS LIST
        // ==========================================
        Expanded(
          child: _buildRecordsList(provider),
        ),
      ],
      ),
    );
  }

  Widget _buildRecordsList(FloodDataProvider provider) {
    if (provider.isLoading && provider.floodData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.floodData.isEmpty) {
      return Center(
        child: Text(
          'Failed to load records.\n${provider.errorMessage}',
          style: AppTextStyles.bodySecondary,
          textAlign: TextAlign.center,
        ),
      );
    }

    // Apply filters
    final filteredData = provider.floodData.where((station) {
      // 1. Status Filter
      if (_selectedStatusFilter != 'ALL') {
        final stationStatus = station.waterLevelIndicator ?? 'NORMAL';
        if (stationStatus != _selectedStatusFilter) {
          return false;
        }
      }

      // 2. Search Query
      if (_searchQuery.isNotEmpty) {
        final matchName = station.stationName.toLowerCase().contains(_searchQuery);
        final matchDistrict = station.district.toLowerCase().contains(_searchQuery);
        final matchState = station.state.toLowerCase().contains(_searchQuery);
        final matchMainBasin = station.mainBasin.toLowerCase().contains(_searchQuery);
        final matchSubBasin = station.subBasin.toLowerCase().contains(_searchQuery);

        if (!matchName && !matchDistrict && !matchState && !matchMainBasin && !matchSubBasin) {
          return false;
        }
      }

      return true;
    }).toList();

    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'No records found',
              style: AppTextStyles.heading,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or filter.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedStatusFilter = 'ALL';
                });
                provider.fetchFloodData();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: filteredData.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final station = filteredData[index];
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
}
