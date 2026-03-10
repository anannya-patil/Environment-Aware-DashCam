import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';

import '../models/sensor_data.dart';

class SensorManager
{
  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _gyroscopeSubscription;
  StreamSubscription? _positionSubscription;

  double _accelX = 0;
  double _accelY = 0;
  double _accelZ = 0;

  double _gyroX = 0;
  double _gyroY = 0;
  double _gyroZ = 0;

  double _speed = 0;

  Function(SensorData)? onSensorData;

  Future<void> startSensorCollection() async
  {
    await _requestLocationPermission();

    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event)
    {
      _accelX = event.x;
      _accelY = event.y;
      _accelZ = event.z;

      _emitSensorData();
    });

    _gyroscopeSubscription=gyroscopeEventStream().listen((GyroscopeEvent event)
    {
      _gyroX = event.x;
      _gyroY = event.y;
      _gyroZ = event.z;
    });

    _positionSubscription =
        Geolocator.getPositionStream().listen((Position position)
    {
      _speed = position.speed * 3.6;   //convert m/s to km/h
    });

    print("[Sensor] Sensor collection started");
  }

  void stopSensorCollection()
  {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _positionSubscription?.cancel();

    print("[Sensor] Sensor collection stopped");
  }

  void _emitSensorData()
  {
    final data = SensorData(
      timestamp: DateTime.now(),
      speed: _speed,
      accelX: _accelX,
      accelY: _accelY,
      accelZ: _accelZ,
      gyroX: _gyroX,
      gyroY: _gyroY,
      gyroZ: _gyroZ,
    );

    print("[Sensor] Speed: ${data.speed.toStringAsFixed(2)} km/h");

    if(onSensorData != null)
    {
      onSensorData!(data);
    }
  }

  Future<void> _requestLocationPermission() async
  {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if(permission == LocationPermission.denied)
    {
      permission = await Geolocator.requestPermission();
    }
  }
}