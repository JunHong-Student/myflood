import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  bool _alertsEnabled = false;
  
  List<String> get favoriteIds => _favoriteIds;
  bool get alertsEnabled => _alertsEnabled;

  FavoritesProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _loadFavoritesFromFirestore(user.uid);
      } else {
        _favoriteIds.clear();
        _alertsEnabled = false;
        notifyListeners();
      }
    });
  }

  Future<void> _loadFavoritesFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _favoriteIds = List<String>.from(data['favorites'] ?? []);
        _alertsEnabled = data['alertsEnabled'] ?? false;
      } else {
        _favoriteIds = [];
        _alertsEnabled = false;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> toggleFavorite(String stationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    if (_favoriteIds.contains(stationId)) {
      _favoriteIds.remove(stationId);
      notifyListeners();
      await docRef.set({
        'favorites': FieldValue.arrayRemove([stationId])
      }, SetOptions(merge: true));
    } else {
      _favoriteIds.add(stationId);
      notifyListeners();
      await docRef.set({
        'favorites': FieldValue.arrayUnion([stationId])
      }, SetOptions(merge: true));
    }
  }

  Future<void> toggleAlerts(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _alertsEnabled = value;
    notifyListeners();

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await docRef.set({
      'alertsEnabled': value
    }, SetOptions(merge: true));
  }

  Future<void> clearAll() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _favoriteIds.clear();
    notifyListeners();

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await docRef.set({
      'favorites': []
    }, SetOptions(merge: true));
  }

  bool isFavorite(String stationId) {
    return _favoriteIds.contains(stationId);
  }
}
