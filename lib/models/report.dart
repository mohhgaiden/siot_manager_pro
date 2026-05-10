class ReportModel {
  final String week;
  final String startDate;
  final String endDate;

  final double avgTemperature;
  final double maxTemperature;
  final double minTemperature;

  final double avgHumidity;
  final double maxHumidity;
  final double minHumidity;

  final double avgIllumination;
  final double maxIllumination;
  final double minIllumination;

  final double avgPressure;
  final double maxPressure;
  final double minPressure;

  final double avgVoltage;
  final double maxVoltage;
  final double minVoltage;

  final double avgAmperage;
  final double maxAmperage;
  final double minAmperage;

  final double avgLevel;
  final double maxLevel;
  final double minLevel;

  // ───────── TEMPERATURE ─────────
  final DateTime? maxTempDateTime;
  final String? maxTempTagName;

  final DateTime? minTempDateTime;
  final String? minTempTagName;

  // ───────── HUMIDITY ─────────
  final DateTime? maxHumdDateTime;
  final String? maxHumdTagName;

  final DateTime? minHumdDateTime;
  final String? minHumdTagName;

  // ───────── ILLUMINATION ─────────
  final DateTime? maxIlluminationDateTime;
  final String? maxIlluminationTagName;

  final DateTime? minIlluminationDateTime;
  final String? minIlluminationTagName;

  // ───────── PRESSURE ─────────
  final DateTime? maxPressionDateTime;
  final String? maxPressionTagName;

  final DateTime? minPressionDateTime;
  final String? minPressionTagName;

  // ───────── VOLTAGE ─────────
  final DateTime? maxVoltageDateTime;
  final String? maxVoltageTagName;

  final DateTime? minVoltageDateTime;
  final String? minVoltageTagName;

  // ───────── AMPERAGE ─────────
  final DateTime? maxAmperageDateTime;
  final String? maxAmperageTagName;

  final DateTime? minAmperageDateTime;
  final String? minAmperageTagName;

  // ───────── LEVEL ─────────
  final DateTime? maxLevelDateTime;
  final String? maxLevelTagName;

  final DateTime? minLevelDateTime;
  final String? minLevelTagName;

  final String? spaceStkg;

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

    this.maxTempDateTime,
    this.maxTempTagName,
    this.minTempDateTime,
    this.minTempTagName,

    this.maxHumdDateTime,
    this.maxHumdTagName,
    this.minHumdDateTime,
    this.minHumdTagName,

    this.maxIlluminationDateTime,
    this.maxIlluminationTagName,
    this.minIlluminationDateTime,
    this.minIlluminationTagName,

    this.maxPressionDateTime,
    this.maxPressionTagName,
    this.minPressionDateTime,
    this.minPressionTagName,

    this.maxVoltageDateTime,
    this.maxVoltageTagName,
    this.minVoltageDateTime,
    this.minVoltageTagName,

    this.maxAmperageDateTime,
    this.maxAmperageTagName,
    this.minAmperageDateTime,
    this.minAmperageTagName,

    // LEVEL
    this.maxLevelDateTime,
    this.maxLevelTagName,
    this.minLevelDateTime,
    this.minLevelTagName,

    this.spaceStkg,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return ReportModel(
      week: json["week"] ?? '',
      startDate: json["start_date"] ?? '',
      endDate: json["end_date"] ?? '',

      avgTemperature: parseDouble(json["average_temperature"]),
      maxTemperature: parseDouble(json["max_temperature"]),
      minTemperature: parseDouble(json["min_temperature"]),

      avgHumidity: parseDouble(json["average_humidity"]),
      maxHumidity: parseDouble(json["max_humidity"]),
      minHumidity: parseDouble(json["min_humidity"]),

      avgIllumination: parseDouble(json["average_illumination"]),
      maxIllumination: parseDouble(json["max_illumination"]),
      minIllumination: parseDouble(json["min_illumination"]),

      avgPressure: parseDouble(json["average_pression"]),
      maxPressure: parseDouble(json["max_pression"]),
      minPressure: parseDouble(json["min_pression"]),

      avgVoltage: parseDouble(json["average_voltage"]),
      maxVoltage: parseDouble(json["max_voltage"]),
      minVoltage: parseDouble(json["min_voltage"]),

      avgAmperage: parseDouble(json["average_amperage"]),
      maxAmperage: parseDouble(json["max_amperage"]),
      minAmperage: parseDouble(json["min_amperage"]),

      avgLevel: parseDouble(json["average_level"]),
      maxLevel: parseDouble(json["max_level"]),
      minLevel: parseDouble(json["min_level"]),

      // ───────── TEMPERATURE ─────────
      maxTempDateTime: parseDate(json["max_temp_datetime"]),
      maxTempTagName: json["max_temp_tag_name"],

      minTempDateTime: parseDate(json["min_temp_datetime"]),
      minTempTagName: json["min_temp_tag_name"],

      // ───────── HUMIDITY ─────────
      maxHumdDateTime: parseDate(json["max_humd_datetime"]),
      maxHumdTagName: json["max_humd_tag_name"],

      minHumdDateTime: parseDate(json["min_humd_datetime"]),
      minHumdTagName: json["min_humd_tag_name"],

      // ───────── ILLUMINATION ─────────
      maxIlluminationDateTime: parseDate(json["max_illumination_datetime"]),
      maxIlluminationTagName: json["max_illumination_tag_name"],

      minIlluminationDateTime: parseDate(json["min_illumination_datetime"]),
      minIlluminationTagName: json["min_illumination_tag_name"],

      // ───────── PRESSURE ─────────
      maxPressionDateTime: parseDate(json["max_pression_datetime"]),
      maxPressionTagName: json["max_pression_tag_name"],

      minPressionDateTime: parseDate(json["min_pression_datetime"]),
      minPressionTagName: json["min_pression_tag_name"],

      // ───────── VOLTAGE ─────────
      maxVoltageDateTime: parseDate(json["max_voltage_datetime"]),
      maxVoltageTagName: json["max_voltage_tag_name"],

      minVoltageDateTime: parseDate(json["min_voltage_datetime"]),
      minVoltageTagName: json["min_voltage_tag_name"],

      // ───────── AMPERAGE ─────────
      maxAmperageDateTime: parseDate(json["max_amperage_datetime"]),
      maxAmperageTagName: json["max_amperage_tag_name"],

      minAmperageDateTime: parseDate(json["min_amperage_datetime"]),
      minAmperageTagName: json["min_amperage_tag_name"],

      // ───────── LEVEL ─────────
      maxLevelDateTime: parseDate(json["max_level_datetime"]),
      maxLevelTagName: json["max_level_tag_name"],

      minLevelDateTime: parseDate(json["min_level_datetime"]),
      minLevelTagName: json["min_level_tag_name"],

      spaceStkg: json["space_stkg"],
    );
  }
}
