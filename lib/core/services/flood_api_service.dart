import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flood_data.dart';

class FloodApiService {
  static const String _baseUrl = 'https://api.data.gov.my/flood-warning';

  Future<List<FloodData>> fetchFloodData() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        
        return jsonList
            .map((json) => FloodData.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching flood data: $e');
    }
  }
}
