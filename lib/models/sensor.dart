class Sensor {
  final String id;
  final String name;
  final String mac;
  final double temperature;
  final double humidity;
  final double luminosity;
  final double pressure;
  final int co2;
  final DateTime lastUpdate;
  final bool isLive;
  final String space;

  const Sensor({
    required this.id,
    required this.name,
    required this.mac,
    required this.temperature,
    required this.humidity,
    required this.luminosity,
    required this.pressure,
    required this.co2,
    required this.lastUpdate,
    this.isLive = true,
    required this.space,
  });
}

class SensorReading {
  final DateTime time;
  final double temperature;
  final double humidity;
  final double luminosity;
  final double pressure;
  final int co2;

  const SensorReading({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.luminosity,
    required this.pressure,
    required this.co2,
  });
}

class Alert {
  final String id;
  final String title;
  final String sensorName;
  final DateTime time;
  final AlertType type;
  final String value;
  final bool resolved;

  const Alert({
    required this.id,
    required this.title,
    required this.sensorName,
    required this.time,
    required this.type,
    required this.value,
    this.resolved = false,
  });
}

enum AlertType { danger, warning, success }

// Mock data
class MockData {
  static final List<Sensor> sensors = [
    Sensor(
      id: '0001',
      name: 'Capteur 0001',
      mac: 'F9:DF:52:54:F5:F9',
      temperature: 19.0,
      humidity: 62.0,
      luminosity: 0.04,
      pressure: 1013.0,
      co2: 412,
      lastUpdate: DateTime(2022, 3, 30, 10, 25, 52),
      space: 'Chambre 1',
    ),
    Sensor(
      id: 'mourad',
      name: 'Capteur Mourad',
      mac: 'FD:F4:CC:E5:D3:21',
      temperature: 23.15,
      humidity: 55.0,
      luminosity: 0.11,
      pressure: 1009.0,
      co2: 438,
      lastUpdate: DateTime(2022, 4, 19, 9, 27, 22),
      space: 'Chambre 1',
    ),
  ];

  static List<SensorReading> generateReadings() {
    final now = DateTime.now();
    return List.generate(24, (i) {
      return SensorReading(
        time: now.subtract(Duration(hours: 23 - i)),
        temperature: 18 + (i % 7) * 0.8 + (i > 12 ? -1.5 : 0),
        humidity: 50 + (i % 5) * 3.0 - (i > 15 ? 8 : 0),
        luminosity: i > 6 && i < 20 ? 0.02 + (i % 4) * 0.03 : 0.0,
        pressure: 1010 + (i % 3),
        co2: 400 + (i % 8) * 10,
      );
    });
  }

  static final List<Alert> alerts = [
    Alert(
      id: '1',
      title: 'Température élevée',
      sensorName: 'Capteur 0001',
      time: DateTime(2022, 3, 30, 10, 25),
      type: AlertType.danger,
      value: '35°C',
    ),
    Alert(
      id: '2',
      title: 'Humidité faible',
      sensorName: 'Capteur Mourad',
      time: DateTime(2022, 4, 19, 9, 27),
      type: AlertType.warning,
      value: '28%',
    ),
    Alert(
      id: '3',
      title: 'CO₂ normalisé',
      sensorName: 'Capteur 0001',
      time: DateTime(2022, 3, 28, 14, 10),
      type: AlertType.success,
      value: 'OK',
      resolved: true,
    ),
    Alert(
      id: '4',
      title: 'Connexion rétablie',
      sensorName: 'Capteur Mourad',
      time: DateTime(2022, 3, 15, 8, 0),
      type: AlertType.success,
      value: 'OK',
      resolved: true,
    ),
  ];
}
