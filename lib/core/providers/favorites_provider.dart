import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _prefsKey = 'favorite_station_ids';
  List<String> _favoriteIds = [];

  List<String> get favoriteIds => _favoriteIds;

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds = prefs.getStringList(_prefsKey) ?? [];
    notifyListeners();
  }

  Future<void> toggleFavorite(String stationId) async {
    final prefs = await SharedPreferences.getInstance();
    if (_favoriteIds.contains(stationId)) {
      _favoriteIds.remove(stationId);
    } else {
      _favoriteIds.add(stationId);
    }
    await prefs.setStringList(_prefsKey, _favoriteIds);
    notifyListeners();
  }

  bool isFavorite(String stationId) {
    return _favoriteIds.contains(stationId);
  }
}
