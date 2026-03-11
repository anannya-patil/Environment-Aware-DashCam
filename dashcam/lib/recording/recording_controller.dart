import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'recording_manager.dart';
import '../sensors/sensor_manager.dart';
import '../models/sensor_data.dart';

class RecordingController extends StatefulWidget {
  const RecordingController({super.key});

  @override
  State<RecordingController> createState() => _RecordingControllerState();
}

class _RecordingControllerState extends State<RecordingController> {

  final RecordingManager manager = RecordingManager();
  final SensorManager sensorManager = SensorManager();

  bool autoTriggered = false;
  bool isRecording = false;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();

    sensorManager.onSensorData = (SensorData data) {

      // Auto start recording if speed greater than 0.5 km/h
      if(data.speed > 0.5 && !isRecording && !autoTriggered) {

        autoTriggered = true;

        print("[Auto] Vehicle moving. Starting recording...");

        manager.startRecording();

        setState(() {
          isRecording = true;
        });

      }

    };

    sensorManager.startSensorCollection();
  }

  Future<void> initializeCamera() async {
    await manager.initializeCamera();

    setState(() {
      isCameraInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (!isCameraInitialized || manager.controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashcam Recorder"),
      ),

      body: Stack(
        children: [

          // Camera Preview
          CameraPreview(manager.controller!),

          // Recording Indicator
          if (isRecording)
            const Positioned(
              top: 20,
              left: 20,
              child: Row(
                children: [
                  Icon(Icons.circle, color: Colors.red, size: 14),
                  SizedBox(width: 8),
                  Text(
                    "REC",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {

          if (!isRecording) {

            await manager.startRecording();

          } else {

            final path = await manager.stopRecording();

            debugPrint("Video saved at: $path");

          }

          setState(() {
            isRecording = !isRecording;
          });

        },

        child: Icon(
          isRecording ? Icons.stop : Icons.videocam,
        ),
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