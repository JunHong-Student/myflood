import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/flood_data_provider.dart';
import '../../core/models/flood_data.dart';

class FloodAnalyticsScreen extends StatefulWidget {
  const FloodAnalyticsScreen({super.key});

  @override
  State<FloodAnalyticsScreen> createState() => _FloodAnalyticsScreenState();
}

class _FloodAnalyticsScreenState extends State<FloodAnalyticsScreen> {
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Active Flood Threats by State'),
          _buildLiveThreatsChart(),
          const SizedBox(height: 24),
          _buildSectionTitle('Historical Floods by State (2000-2010)'),
          _buildHistoricalStateChart(),
          const SizedBox(height: 24),
          _buildSectionTitle('Seasonal Flood Patterns'),
          _buildSeasonalChart(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLiveThreatsChart() {
    return Consumer<FloodDataProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Aggregate by state for threats (exclude normal)
        final Map<String, int> stateThreats = {};
        for (var data in provider.floodData) {
          if (data.waterLevelIndicator != null && 
              data.waterLevelIndicator!.toLowerCase() != 'normal' &&
              data.waterLevelIndicator!.toLowerCase() != 'no data') {
            final state = data.state;
            stateThreats[state] = (stateThreats[state] ?? 0) + 1;
          }
        }

        if (stateThreats.isEmpty) {
          return Container(
            height: 150,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'No active flood threats detected.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        final sortedEntries = stateThreats.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (sortedEntries.first.value.toDouble() + 5),
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < sortedEntries.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              sortedEntries[value.toInt()].key,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 != 0) return const SizedBox.shrink();
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: sortedEntries.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.value.toDouble(),
                      color: AppColors.critical,
                      width: 14,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoricalStateChart() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('reko_historical_stats').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error loading historical data',
              style: TextStyle(color: AppColors.critical),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final Map<String, int> stateTotals = {};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final state = data['state'] as String? ?? 'Unknown';
          final events = int.tryParse(data['total_flood_events'].toString()) ?? 0;
          stateTotals[state] = (stateTotals[state] ?? 0) + events;
        }

        if (stateTotals.isEmpty) return const SizedBox.shrink();

        final sortedEntries = stateTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (sortedEntries.first.value.toDouble() + 50),
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < sortedEntries.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              sortedEntries[value.toInt()].key,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: sortedEntries.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.value.toDouble(),
                      color: AppColors.primaryBlue,
                      width: 14,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeasonalChart() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('kaggle_monthly_stats').orderBy('month').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error loading seasonal data',
              style: TextStyle(color: AppColors.critical),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const SizedBox.shrink();

        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // Legend
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendItem(color: AppColors.primaryBlue, label: 'Floods'),
                  SizedBox(width: 12),
                  _LegendItem(color: AppColors.warning, label: 'Flash Floods'),
                  SizedBox(width: 12),
                  _LegendItem(color: AppColors.normal, label: 'Avg Rainfall', isLine: true),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    lineTouchData: const LineTouchData(enabled: false),
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                            if (value.toInt() >= 1 && value.toInt() <= 12) {
                              return Text(
                                months[value.toInt() - 1],
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 1,
                    maxX: 12,
                    minY: 0,
                    lineBarsData: [
                      // Floods
                      LineChartBarData(
                        spots: docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return FlSpot(
                            double.tryParse(data['month'].toString()) ?? 0.0,
                            double.tryParse(data['total_floods'].toString()) ?? 0.0,
                          );
                        }).toList(),
                        isCurved: true,
                        color: AppColors.primaryBlue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                      ),
                      // Flash Floods
                      LineChartBarData(
                        spots: docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return FlSpot(
                            double.tryParse(data['month'].toString()) ?? 0.0,
                            double.tryParse(data['total_flash_floods'].toString()) ?? 0.0,
                          );
                        }).toList(),
                        isCurved: true,
                        color: AppColors.warning,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                      ),
                      // Avg Rainfall
                      LineChartBarData(
                        spots: docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return FlSpot(
                            double.tryParse(data['month'].toString()) ?? 0.0,
                            double.tryParse(data['avg_rainfall'].toString()) ?? 0.0,
                          );
                        }).toList(),
                        isCurved: true,
                        color: AppColors.normal,
                        barWidth: 2,
                        dashArray: [5, 5],
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isLine;

  const _LegendItem({
    required this.color,
    required this.label,
    this.isLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isLine)
          Container(
            width: 12,
            height: 2,
            color: color,
          )
        else
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
