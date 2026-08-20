import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppShell extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;
  final VoidCallback onLogout;

  const AppShell({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onNavigationChanged,
    required this.onLogout,
  });

  static const List<String> navigationLabels = [
    'Dashboard',
    'Flood Records',
    'Favorites',
    'Flood Map',
  ];

  static const List<IconData> navigationIcons = [
    Icons.dashboard_outlined,
    Icons.list_alt_outlined,
    Icons.favorite_border_outlined,
    Icons.map_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // TOP HEADER
            // ==========================================

            Container(
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),

                  // App name
                  const Expanded(
                    child: Text(
                      'MyFlood Malaysia',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // Status indicator
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.normal,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 6),

                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(width: 12),

                  IconButton(
                    onPressed: onLogout,
                    tooltip: 'Logout',
                    icon: const Icon(
                      Icons.logout,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 8),
                ],
              ),
            ),

            // ==========================================
            // NAVIGATION
            // ==========================================

            Container(
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    navigationLabels.length,
                        (index) {
                      final bool selected = index == currentIndex;

                      return GestureDetector(
                        onTap: () {
                          onNavigationChanged(index);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: selected
                                ? const Border(
                              bottom: BorderSide(
                                color: AppColors.primaryBlue,
                                width: 2,
                              ),
                            )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                navigationIcons[index],
                                size: 15,
                                color: selected
                                    ? AppColors.primaryBlue
                                    : AppColors.textSecondary,
                              ),

                              const SizedBox(width: 6),

                              Text(
                                navigationLabels[index],
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ==========================================
            // PAGE CONTENT
            // ==========================================

            Expanded(
              child: body,
            ),
          ],
        ),
      ),
    );
  }
}