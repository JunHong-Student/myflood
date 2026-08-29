import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/providers/flood_data_provider.dart';
import 'core/providers/favorites_provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FloodDataProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ],
        child: const MyFloodApp(),
      ),
    );
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