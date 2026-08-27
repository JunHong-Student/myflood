import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/widgets/app_shell.dart';
import '../auth/login_screen.dart';
import 'dashboard_screen.dart';
import 'flood_records_screen.dart';
import 'favorites_screen.dart';
import 'flood_map_screen.dart';
import 'flood_analytics_screen.dart';
import 'emergency_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: currentIndex,

      onNavigationChanged: (index) {
        setState(() {
          currentIndex = index;
        });
        _pageController.jumpToPage(index);
      },

      onLogout: _logout,

      body: PageView(
        controller: _pageController,
        physics: currentIndex == 3 
            ? const NeverScrollableScrollPhysics() 
            : const BouncingScrollPhysics(),
        onPageChanged: (index) {
          FocusScope.of(context).unfocus();
          setState(() {
            currentIndex = index;
          });
        },
        children: [
          DashboardScreen(
            onTabSwitch: (index) {
              setState(() {
                currentIndex = index;
              });
              _pageController.jumpToPage(index);
            },
          ),
          const FloodRecordsScreen(),
          const FavoritesScreen(),
          const FloodMapScreen(),
          const FloodAnalyticsScreen(),
          const EmergencyScreen(),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    }
  }
}