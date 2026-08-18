import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const MyFloodApp());
}

class MyFloodApp extends StatelessWidget {
  const MyFloodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'MyFlood Malaysia',

      theme: AppTheme.darkTheme,

      home: const SplashScreen(),
    );
  }
}