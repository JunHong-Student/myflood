import 'package:flutter/material.dart';
import '../models/flood_data.dart';
import '../services/flood_api_service.dart';

class FloodDataProvider extends ChangeNotifier {
  final FloodApiService _apiService = FloodApiService();

  List<FloodData> _floodData = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FloodData> get floodData => _floodData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFloodData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _floodData = await _apiService.fetchFloodData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
