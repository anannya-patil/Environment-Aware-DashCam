import 'package:flutter/material.dart';
import 'sensors/sensor_manager.dart';
import 'models/sensor_data.dart';
import 'recording/recording_controller.dart';
import 'utils/emergency_service.dart'; // ✅ ADDED

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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              const SizedBox(height: 20),

              const Text(
                "DashCam",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              _buildCard(
                context,
                title: "Sensor Test",
                icon: Icons.sensors,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SensorTestPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              _buildCard(
                context,
                title: "Start Dashcam",
                icon: Icons.videocam,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecordingController(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 🔥 NEW EMERGENCY TEST BUTTON
              _buildCard(
                context,
                title: "Test Emergency",
                icon: Icons.warning,
                onTap: () {
                  EmergencyService.trigger(context);
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 30),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
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