class ReportModel {
  final String week;
  final DateTime startDate;
  final DateTime endDate;

  // ─── Temperature ─────────────────────────────
  final double avgTemperature;
  final double maxTemperature;
  final double minTemperature;

  // ─── Humidity ───────────────────────────────
  final double avgHumidity;
  final double maxHumidity;
  final double minHumidity;

  // ─── Illumination ───────────────────────────
  final double avgIllumination;
  final double maxIllumination;
  final double minIllumination;

  // ─── Pressure ───────────────────────────────
  final double avgPressure;
  final double maxPressure;
  final double minPressure;

  // ─── Voltage ────────────────────────────────
  final double avgVoltage;
  final double maxVoltage;
  final double minVoltage;

  // ─── Amperage ───────────────────────────────
  final double avgAmperage;
  final double maxAmperage;
  final double minAmperage;

  // ─── Level ──────────────────────────────────
  final double avgLevel;
  final double maxLevel;
  final double minLevel;

  ReportModel({
    required this.week,
    required this.startDate,
    required this.endDate,

    required this.avgTemperature,
    required this.maxTemperature,
    required this.minTemperature,

    required this.avgHumidity,
    required this.maxHumidity,
    required this.minHumidity,

    required this.avgIllumination,
    required this.maxIllumination,
    required this.minIllumination,

    required this.avgPressure,
    required this.maxPressure,
    required this.minPressure,

    required this.avgVoltage,
    required this.maxVoltage,
    required this.minVoltage,

    required this.avgAmperage,
    required this.maxAmperage,
    required this.minAmperage,

    required this.avgLevel,
    required this.maxLevel,
    required this.minLevel,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    double parse(dynamic v) => (v ?? 0).toDouble();

    return ReportModel(
      week: json['week'] ?? '',

      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),

      // ─── Temperature
      avgTemperature: parse(json['average_temperature']),
      maxTemperature: parse(json['max_temperature']),
      minTemperature: parse(json['min_temperature']),

      // ─── Humidity
      avgHumidity: parse(json['average_humidity']),
      maxHumidity: parse(json['max_humidity']),
      minHumidity: parse(json['min_humidity']),

      // ─── Illumination
      avgIllumination: parse(json['average_illumination']),
      maxIllumination: parse(json['max_illumination']),
      minIllumination: parse(json['min_illumination']),

      // ─── Pressure
      avgPressure: parse(json['average_pression']),
      maxPressure: parse(json['max_pression']),
      minPressure: parse(json['min_pression']),

      // ─── Voltage
      avgVoltage: parse(json['average_voltage']),
      maxVoltage: parse(json['max_voltage']),
      minVoltage: parse(json['min_voltage']),

      // ─── Amperage
      avgAmperage: parse(json['average_amperage']),
      maxAmperage: parse(json['max_amperage']),
      minAmperage: parse(json['min_amperage']),

      // ─── Level
      avgLevel: parse(json['average_level']),
      maxLevel: parse(json['max_level']),
      minLevel: parse(json['min_level']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week': week,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),

      // Temperature
      'average_temperature': avgTemperature,
      'max_temperature': maxTemperature,
      'min_temperature': minTemperature,

      // Humidity
      'average_humidity': avgHumidity,
      'max_humidity': maxHumidity,
      'min_humidity': minHumidity,

      // Illumination
      'average_illumination': avgIllumination,
      'max_illumination': maxIllumination,
      'min_illumination': minIllumination,

      // Pressure
      'average_pression': avgPressure,
      'max_pression': maxPressure,
      'min_pression': minPressure,

      // Voltage
      'average_voltage': avgVoltage,
      'max_voltage': maxVoltage,
      'min_voltage': minVoltage,

      // Amperage
      'average_amperage': avgAmperage,
      'max_amperage': maxAmperage,
      'min_amperage': minAmperage,

      // Level
      'average_level': avgLevel,
      'max_level': maxLevel,
      'min_level': minLevel,
    };
  }
}
