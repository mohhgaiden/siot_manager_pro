class DayGraphModel {
  final String nameDay;
  final String dateDay;

  final double avgTemp, maxTemp, minTemp;
  final double avgHumidity, maxHumidity, minHumidity;
  final double avgIllumination, maxIllumination, minIllumination;
  final double avgPression, minPression;
  final double avgVoltage, maxVoltage, minVoltage;
  final double avgAmperage, maxAmperage, minAmperage;
  final double avgLevel, maxLevel, minLevel;

  const DayGraphModel({
    required this.nameDay,
    required this.dateDay,
    required this.avgTemp,
    required this.maxTemp,
    required this.minTemp,
    required this.avgHumidity,
    required this.maxHumidity,
    required this.minHumidity,
    required this.avgIllumination,
    required this.maxIllumination,
    required this.minIllumination,
    required this.avgPression,
    required this.minPression,
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

  factory DayGraphModel.fromJson(Map<String, dynamic> json) {
    double v(String key) => (json[key] as num?)?.toDouble() ?? 0;
    return DayGraphModel(
      nameDay: json['name_day'] ?? '',
      dateDay: json['date_day'] ?? '',
      avgTemp: v('average_temperature'),
      maxTemp: v('max_temperature'),
      minTemp: v('min_temperature'),
      avgHumidity: v('average_humidity'),
      maxHumidity: v('max_humidity'),
      minHumidity: v('min_humidity'),
      avgIllumination: v('average_illumination'),
      maxIllumination: v('max_illumination'),
      minIllumination: v('min_illumination'),
      avgPression: v('average_pression'),
      minPression: v('min_pression'),
      avgVoltage: v('average_voltage'),
      maxVoltage: v('max_voltage'),
      minVoltage: v('min_voltage'),
      avgAmperage: v('average_amperage'),
      maxAmperage: v('max_amperage'),
      minAmperage: v('min_amperage'),
      avgLevel: v('average_level'),
      maxLevel: v('max_level'),
      minLevel: v('min_level'),
    );
  }

  // ✅ Returns (min, avg, max) for any metric
  (double, double, double) values(String metric) {
    switch (metric) {
      case 'temperature':
        return (minTemp, avgTemp, maxTemp);
      case 'humidity':
        return (minHumidity, avgHumidity, maxHumidity);
      case 'illumination':
        return (minIllumination, avgIllumination, maxIllumination);
      case 'pression':
        return (minPression, avgPression, avgPression);
      case 'voltage':
        return (minVoltage, avgVoltage, maxVoltage);
      case 'amperage':
        return (minAmperage, avgAmperage, maxAmperage);
      case 'level':
        return (minLevel, avgLevel, maxLevel);
      default:
        return (0, 0, 0);
    }
  }
}
