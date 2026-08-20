import 'package:flutter/material.dart';

import '../../core/widgets/app_shell.dart';
import '../auth/login_screen.dart';
import 'dashboard_screen.dart';
import 'flood_records_screen.dart';
import 'favorites_screen.dart';
import 'flood_map_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: currentIndex,

      onNavigationChanged: (index) {
        setState(() {
          currentIndex = index;
        });
      },

      onLogout: _logout,

      body: _buildPage(),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  Widget _buildPage() {
    switch (currentIndex) {
      case 0:
        return const DashboardScreen();

      case 1:
        return const FloodRecordsScreen();

      case 2:
        return const FavoritesScreen();

      case 3:
        return const FloodMapScreen();

      default:
        return const DashboardScreen();
    }
  }
}