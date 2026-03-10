class SensorData
{
  final DateTime timestamp;

  final double speed;

  final double accelX;
  final double accelY;
  final double accelZ;

  final double gyroX;
  final double gyroY;
  final double gyroZ;

  SensorData(
  {
    required this.timestamp,
    required this.speed,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ
  });
}