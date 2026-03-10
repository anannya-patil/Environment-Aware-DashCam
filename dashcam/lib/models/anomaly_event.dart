import 'sensor_data.dart';

class AnomalyEvent
{
  final String type;
  final DateTime timestamp;
  final double severity;
  final SensorData sensorSnapshot;

  AnomalyEvent(
  {
    required this.type,
    required this.timestamp,
    required this.severity,
    required this.sensorSnapshot
  });
}