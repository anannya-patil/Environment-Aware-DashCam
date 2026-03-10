import 'package:flutter/material.dart';
import 'sensors/sensor_manager.dart';
import 'models/sensor_data.dart';
import 'recording/recording_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Environment Aware DashCam"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SensorTestPage(),
                  ),
                );
              },
              child: const Text("Open Sensor Test"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecordingController(),
                  ),
                );
              },
              child: const Text("Open Dashcam Recorder"),
            ),
          ],
        ),
      ),
    );
  }
}

class SensorTestPage extends StatefulWidget {
  const SensorTestPage({super.key});

  @override
  State<SensorTestPage> createState() {
    return _SensorTestPageState();
  }
}

class _SensorTestPageState extends State<SensorTestPage> {
  final SensorManager sensorManager = SensorManager();

  double speed = 0;
  double ax = 0;
  double ay = 0;
  double az = 0;

  @override
  void initState() {
    super.initState();

    sensorManager.onSensorData = (SensorData data) {
      setState(() {
        speed = data.speed;
        ax = data.accelX;
        ay = data.accelY;
        az = data.accelZ;
      });
    };

    sensorManager.startSensorCollection();
  }

  @override
  void dispose() {
    sensorManager.stopSensorCollection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sensor Test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              "Speed: ${speed.toStringAsFixed(2)} km/h",
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),

            Text("Accel X: ${ax.toStringAsFixed(2)}"),
            Text("Accel Y: ${ay.toStringAsFixed(2)}"),
            Text("Accel Z: ${az.toStringAsFixed(2)}"),

          ],
        ),
      ),
    );
  }
}