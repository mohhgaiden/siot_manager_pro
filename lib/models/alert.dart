class AlertModel {
  final String spaceName;
  final String tagName;
  final String macAdrs;
  final String name;
  final DateTime dateTime;
  final int min;
  final int max;
  final int type;
  final double temperature;
  final double humidity;

  AlertModel({
    required this.spaceName,
    required this.tagName,
    required this.macAdrs,
    required this.name,
    required this.dateTime,
    required this.min,
    required this.max,
    required this.type,
    required this.temperature,
    required this.humidity,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      spaceName: json['space_name'] ?? '',
      tagName: json['tag_name'] ?? '',
      macAdrs: json['MacAddrs'] ?? '',
      name: json['name_alrt'] ?? '',
      dateTime: _parseDate(json['alrt_date_hr']),
      min: json['alrt_val_min'] ?? 0,
      max: json['alrt_val_max'] ?? 0,
      type: json['alrt_tpe'] ?? 0,
      temperature: (json['alrt_val_temperature'] ?? 0).toDouble(),
      humidity: (json['alrt_val_humd'] ?? 0).toDouble(),
    );
  }

  static DateTime _parseDate(String? date) {
    if (date == null) return DateTime.now();
    try {
      // format: 05-04-2026 16:13:56
      final parts = date.split(' ');
      final d = parts[0].split('-');
      final t = parts[1].split(':');

      return DateTime(
        int.parse(d[2]),
        int.parse(d[1]),
        int.parse(d[0]),
        int.parse(t[0]),
        int.parse(t[1]),
        int.parse(t[2]),
      );
    } catch (_) {
      return DateTime.now();
    }
  }
}
