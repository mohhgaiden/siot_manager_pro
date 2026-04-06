class AccessModel {
  final int temperature;
  final int illumination;
  final int humidity;
  final int pression;
  final int voltage;
  final int amperage;
  final int level;

  AccessModel({
    required this.temperature,
    required this.humidity,
    required this.illumination,
    required this.pression,
    required this.voltage,
    required this.amperage,
    required this.level,
  });

  factory AccessModel.fromJson(Map<String, dynamic> json) {
    return AccessModel(
      temperature: json['temperature'] ?? 0,
      humidity: json['humidity'] ?? 0,
      illumination: json['illumination'] ?? 0,
      pression: json['pression'] ?? 0,
      voltage: json['voltage'] ?? 0,
      amperage: json['amperage'] ?? 0,
      level: json['level'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'illumination': illumination,
      'pression': pression,
      'voltage': voltage,
      'amperage': amperage,
      'level': level,
    };
  }
}
