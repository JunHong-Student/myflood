class FloodData {
  final String stationId;
  final String stationName;
  final double latitude;
  final double longitude;
  final String district;
  final String state;
  final String mainBasin;
  final String subBasin;
  final String stationType;
  
  final double? waterLevelCurrent;
  final String? waterLevelIndicator;
  final double? waterLevelNormalLevel;
  final double? waterLevelAlertLevel;
  final double? waterLevelWarningLevel;
  final double? waterLevelDangerLevel;
  final String? waterLevelUpdateDatetime;

  FloodData({
    required this.stationId,
    required this.stationName,
    required this.latitude,
    required this.longitude,
    required this.district,
    required this.state,
    required this.mainBasin,
    required this.subBasin,
    required this.stationType,
    this.waterLevelCurrent,
    this.waterLevelIndicator,
    this.waterLevelNormalLevel,
    this.waterLevelAlertLevel,
    this.waterLevelWarningLevel,
    this.waterLevelDangerLevel,
    this.waterLevelUpdateDatetime,
  });

  factory FloodData.fromJson(Map<String, dynamic> json) {
    return FloodData(
      stationId: json['station_id']?.toString() ?? '',
      stationName: json['station_name']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      district: json['district']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      mainBasin: json['main_basin']?.toString() ?? '',
      subBasin: json['sub_basin']?.toString() ?? '',
      stationType: json['station_type']?.toString() ?? '',
      waterLevelCurrent: _parseDouble(json['water_level_current']),
      waterLevelIndicator: json['water_level_indicator']?.toString(),
      waterLevelNormalLevel: _parseDouble(json['water_level_normal_level']),
      waterLevelAlertLevel: _parseDouble(json['water_level_alert_level']),
      waterLevelWarningLevel: _parseDouble(json['water_level_warning_level']),
      waterLevelDangerLevel: _parseDouble(json['water_level_danger_level']),
      waterLevelUpdateDatetime: json['water_level_update_datetime']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
