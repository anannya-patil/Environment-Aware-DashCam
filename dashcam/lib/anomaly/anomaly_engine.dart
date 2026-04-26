import 'dart:math';

import '../models/sensor_data.dart';
import '../models/anomaly_event.dart';

class AnomalyEngine {
  // ================= BUFFER =================
  final List<SensorData> _buffer = [];
  final Duration bufferDuration = const Duration(seconds: 5);

  // ================= FRAME COUNTERS =================
  int crashCount = 0;
  int brakeCount = 0;
  int turnCount = 0;
  int impactCount = 0;
  int rolloverCount = 0;

  // ================= COOLDOWN =================
  DateTime? lastTriggerTime;
  final Duration cooldown = const Duration(seconds: 3);

  // 🔥 NEW: CALLBACK
  Function(AnomalyEvent)? onAnomalyDetected;

  // ================= ENTRY =================
  void processSensorData(SensorData data) {
    _addToBuffer(data);

    if (_inCooldown(data.timestamp)) return;

    // 🔥 SYNC FIX (time window)
    final shortWindow = _getRecent(const Duration(milliseconds: 150));
    if (shortWindow.isEmpty) return;

    final accelMag = shortWindow.map((d) => _accelMagnitude(d)).reduce(max);
    final forwardAccel = shortWindow.map((d) => d.accelX).reduce(max);
    final lateralAccel = shortWindow.map((d) => d.accelY.abs()).reduce(max);
    final gyroZ = shortWindow.map((d) => d.gyroZ.abs()).reduce(max);

    final gyroMax = _maxGyro(const Duration(seconds: 1));
    final speedDrop = _computeSpeedDrop(const Duration(seconds: 2));
    final gravityShift = _gravityShift();

    final event = _detectEvent(
      data,
      accelMag,
      speedDrop,
      forwardAccel,
      lateralAccel,
      gyroZ,
      gyroMax,
      gravityShift,
    );

    if (event != null) {
      _handleEvent(event);
      lastTriggerTime = data.timestamp;
    }
  }

  // ================= BUFFER =================
  void _addToBuffer(SensorData data) {
    _buffer.add(data);

    _buffer.removeWhere(
      (d) => data.timestamp.difference(d.timestamp) > bufferDuration,
    );
  }

  List<SensorData> _getRecent(Duration duration) {
    if (_buffer.isEmpty) return [];

    final now = _buffer.last.timestamp;
    return _buffer
        .where((d) => now.difference(d.timestamp) <= duration)
        .toList();
  }

  // ================= DERIVED =================
  double _accelMagnitude(SensorData d) {
    return sqrt(
          d.accelX * d.accelX +
              d.accelY * d.accelY +
              d.accelZ * d.accelZ,
        ) /
        9.81;
  }

  double _computeSpeedDrop(Duration window) {
    final recent = _getRecent(window);
    if (recent.length < 2) return 0;

    return recent.first.speed - recent.last.speed;
  }

  double _maxGyro(Duration window) {
    final recent = _getRecent(window);
    if (recent.isEmpty) return 0;

    return recent
        .map((d) => max(max(d.gyroX.abs(), d.gyroY.abs()), d.gyroZ.abs()))
        .reduce(max);
  }

  double _gravityShift() {
    if (_buffer.isEmpty) return 0;
    return (_accelMagnitude(_buffer.last) - 1.0).abs();
  }

  bool _inCooldown(DateTime now) {
    if (lastTriggerTime == null) return false;
    return now.difference(lastTriggerTime!) < cooldown;
  }

  // ================= CORE DETECTION =================
  AnomalyEvent? _detectEvent(
    SensorData data,
    double accelMag,
    double speedDrop,
    double forwardAccel,
    double lateralAccel,
    double gyroZ,
    double gyroMax,
    double gravityShift,
  ) {
    // ---------- CRASH ----------
    bool crashEmergency =
        accelMag >= 6.0 && data.speed >= 30 && speedDrop >= 30;

    bool crashAnomaly =
        accelMag >= 4.0 && data.speed >= 24 && speedDrop >= 20;

    crashCount = (crashEmergency || crashAnomaly) ? crashCount + 1 : 0;

    if (crashCount >= 2) {
      return _createEvent(
          "CRASH", crashEmergency ? "EMERGENCY" : "ANOMALY");
    }

    // ---------- HARD BRAKE ----------
    bool brakeEmergency =
        speedDrop >= 25 && forwardAccel <= -2.5;

    bool brakeAnomaly =
        speedDrop >= 15 && forwardAccel <= -1.5;

    brakeCount = (brakeEmergency || brakeAnomaly) ? brakeCount + 1 : 0;

    if (brakeCount >= 3) {
      return _createEvent(
          "HARD_BRAKE", brakeEmergency ? "EMERGENCY" : "ANOMALY");
    }

    // ---------- TURN ----------
    bool turnEmergency =
        gyroZ >= 5.0 && lateralAccel >= 2.5 && data.speed >= 30;

    bool turnAnomaly =
        gyroZ >= 3.0 && lateralAccel >= 1.5 && data.speed >= 20;

    turnCount = (turnEmergency || turnAnomaly) ? turnCount + 1 : 0;

    if (turnCount >= 4) {
      return _createEvent(
          "TURN", turnEmergency ? "EMERGENCY" : "ANOMALY");
    }

    // ---------- STATIONARY IMPACT ----------
    bool impactEmergency =
        data.speed <= 5 && accelMag >= 4.0;

    bool impactAnomaly =
        data.speed <= 5 && accelMag >= 2.5;

    impactCount = (impactEmergency || impactAnomaly) ? impactCount + 1 : 0;

    if (impactCount >= 2) {
      return _createEvent(
          "STATIONARY_IMPACT",
          impactEmergency ? "EMERGENCY" : "ANOMALY");
    }

    // ---------- ROLLOVER ----------
    bool rollEmergency =
        gyroMax >= 4.0 && gravityShift >= 1.0;

    bool rollAnomaly =
        gyroMax >= 2.5 && gravityShift >= 0.7;

    rolloverCount =
        (rollEmergency || rollAnomaly) ? rolloverCount + 1 : 0;

    if (rolloverCount >= 6) {
      return _createEvent(
          "ROLLOVER", rollEmergency ? "EMERGENCY" : "ANOMALY");
    }

    return null;
  }

  // ================= EVENT =================
  AnomalyEvent _createEvent(String type, String severity) {
    final snapshot = _getRecent(const Duration(seconds: 2));

    return AnomalyEvent(
      type: type,
      severity: severity,
      timestamp: DateTime.now(),
      sensorSnapshot: snapshot,
    );
  }

  // ================= CALLBACK TRIGGER =================
  void _handleEvent(AnomalyEvent event) {
    if (onAnomalyDetected != null) {
      onAnomalyDetected!(event);
    }
  }
}