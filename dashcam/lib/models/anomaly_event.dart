import 'sensor_data.dart';

class AnomalyEvent {
  final String type;
  final String severity; // ✅ FIXED
  final DateTime timestamp;
  final List<SensorData> sensorSnapshot; // ✅ FIXED

  AnomalyEvent({
    required this.type,
    required this.timestamp,
    required this.severity,
    required this.sensorSnapshot,
  });
}