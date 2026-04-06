class ReportModel {
  final String week;
  final DateTime startDate;
  final DateTime endDate;

  final double avgTemperature;
  final double avgHumidity;
  final double avgIllumination;
  final double avgPressure;
  final double avgVoltage;
  final double avgAmperage;
  final double avgLevel;

  ReportModel({
    required this.week,
    required this.startDate,
    required this.endDate,
    required this.avgTemperature,
    required this.avgHumidity,
    required this.avgIllumination,
    required this.avgPressure,
    required this.avgVoltage,
    required this.avgAmperage,
    required this.avgLevel,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      week: json['week'] ?? '',

      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),

      avgTemperature: (json['average_temperature'] ?? 0).toDouble(),
      avgHumidity: (json['average_humidity'] ?? 0).toDouble(),
      avgIllumination: (json['average_illumination'] ?? 0).toDouble(),
      avgPressure: (json['average_pression'] ?? 0).toDouble(),
      avgVoltage: (json['average_voltage'] ?? 0).toDouble(),
      avgAmperage: (json['average_amperage'] ?? 0).toDouble(),
      avgLevel: (json['average_level'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week': week,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'average_temperature': avgTemperature,
      'average_humidity': avgHumidity,
      'average_illumination': avgIllumination,
      'average_pression': avgPressure,
      'average_voltage': avgVoltage,
      'average_amperage': avgAmperage,
      'average_level': avgLevel,
    };
  }
}
