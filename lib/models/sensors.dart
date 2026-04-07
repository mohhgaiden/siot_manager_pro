class SensorModel {
  final String mac;
  final String name;
  final String type;

  final double temperature;
  final double humidity;
  final double illumination;
  final double pression;
  final double voltage;
  final double amperage;
  final double level;

  final double latitude;
  final double longitude;

  final DateTime dateTime;

  final bool isLive;

  SensorModel({
    required this.mac,
    required this.name,
    required this.type,
    required this.temperature,
    required this.humidity,
    required this.illumination,
    required this.pression,
    required this.voltage,
    required this.amperage,
    required this.level,
    required this.latitude,
    required this.longitude,
    required this.dateTime,
    required this.isLive,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    // Combine date + time
    final date = json['date_reading'] ?? json["date_releve"] ?? '';
    final time = json['heure_reading'] ?? json["heure_releve"] ?? '';

    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(_formatDate(date, time));
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return SensorModel(
      mac: json['MacAddrs'] ?? '',
      name: json['Name'] ?? '',
      type: json['Type'] ?? '',

      temperature: (json['val_temperature'] ?? 0).toDouble(),
      humidity: (json['val_humidity'] ?? 0).toDouble(),
      illumination: (json['val_illumination'] ?? 0).toDouble(),
      pression: (json['val_pression'] ?? 0).toDouble(),
      voltage: (json['val_voltage'] ?? 0).toDouble(),
      amperage: (json['amperage'] ?? 0).toDouble(),
      level: (json['level'] ?? 0).toDouble(),

      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),

      dateTime: parsedDate,

      isLive: DateTime.now().difference(parsedDate).inMinutes < 30,
    );
  }

  static String _formatDate(String date, String time) {
    // API format: dd-MM-yyyy + HH:mm:ss
    final parts = date.split('-'); // [dd, MM, yyyy]
    if (parts.length != 3) return '';

    final formatted =
        '${parts[2]}-${parts[1]}-${parts[0]}T$time'; // yyyy-MM-ddTHH:mm:ss
    return formatted;
  }

  Map<String, dynamic> toJson() {
    return {
      "MacAddrs": mac,
      "Name": name,
      "Type": type,
      "val_temperature": temperature,
      "val_humidity": humidity,
      "val_illumination": illumination,
      "val_pression": pression,
      "val_voltage": voltage,
      "amperage": amperage,
      "level": level,
      "latitude": latitude,
      "longitude": longitude,
      "dateTime": dateTime.toIso8601String(),
    };
  }
}
