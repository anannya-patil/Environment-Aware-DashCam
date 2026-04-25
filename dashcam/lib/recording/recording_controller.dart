import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'recording_manager.dart';
import '../sensors/sensor_manager.dart';
import '../models/sensor_data.dart';
import '../anomaly/anomaly_engine.dart';
import '../models/anomaly_event.dart';
import '../utils/emergency_service.dart';

class RecordingController extends StatefulWidget {
  const RecordingController({super.key});

  @override
  State<RecordingController> createState() => _RecordingControllerState();
}

class _RecordingControllerState extends State<RecordingController> {

  final RecordingManager manager = RecordingManager();
  final SensorManager sensorManager = SensorManager();

  // 🔥 NEW: Anomaly Engine
  final AnomalyEngine anomalyEngine = AnomalyEngine();

  bool autoTriggered = false;
  bool isRecording = false;
  bool isCameraInitialized = false;

  double speed = 0;

  @override
  void initState() {
    super.initState();

    initializeCamera();

    // 🔥 CONNECT CALLBACK
    anomalyEngine.onAnomalyDetected = (AnomalyEvent event) async {

      debugPrint("[ANOMALY DETECTED] ${event.type} - ${event.severity}");

      // Start recording if not already
      if (!manager.controller!.value.isRecordingVideo) {
        try {
          await manager.startRecording();

          setState(() {
            isRecording = true;
          });

        } catch (e) {
          debugPrint("[Recording Error] $e");
        }
      }

      // Trigger emergency ONLY for EMERGENCY
      if (event.severity == "EMERGENCY") {
        EmergencyService.trigger(context);
      }
    };

    // 🔥 SENSOR FLOW
    sensorManager.onSensorData = (SensorData data) {

      speed = data.speed;

      // 🔥 SEND DATA TO ENGINE
      anomalyEngine.processSensorData(data);

      // Existing auto-record (optional safety fallback)
      if (data.speed > 0.5 &&
          manager.controller != null &&
          manager.controller!.value.isInitialized &&
          !manager.controller!.value.isRecordingVideo &&
          !autoTriggered) {

        autoTriggered = true;

        manager.startRecording().then((_) {
          setState(() {
            isRecording = true;
          });
        }).catchError((e) {
          debugPrint("[Auto Error] $e");
        });
      }

      setState(() {});
    };

    sensorManager.startSensorCollection();
  }

  Future<void> initializeCamera() async {
    try {
      await manager.initializeCamera();

      setState(() {
        isCameraInitialized = true;
      });

    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    if (!isCameraInitialized || manager.controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          Positioned.fill(
            child: CameraPreview(manager.controller!),
          ),

          Positioned(
            top: 40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${speed.toStringAsFixed(1)} km/h",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (isRecording)
            Positioned(
              top: 40,
              right: 20,
              child: Row(
                children: const [
                  Icon(Icons.circle, color: Colors.red, size: 12),
                  SizedBox(width: 6),
                  Text(
                    "REC",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {

                  try {

                    if (!manager.controller!.value.isRecordingVideo) {

                      await manager.startRecording();

                      setState(() {
                        isRecording = true;
                      });

                    } else {

                      final path = await manager.stopRecording();

                      debugPrint("Video saved at: $path");

                      setState(() {
                        isRecording = false;
                      });
                    }

                  } catch (e) {
                    debugPrint("Recording error: $e");
                  }
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRecording ? Colors.red : Colors.white,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Icon(
                    isRecording ? Icons.stop : Icons.circle,
                    color: isRecording ? Colors.white : Colors.red,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    sensorManager.stopSensorCollection();
    manager.dispose();
    super.dispose();
  }
}