import '../sensors/sensor_manager.dart';
import '../models/sensor_data.dart';
import '../anomaly/anomaly_engine.dart';
import '../recording/recording_manager.dart';
import 'emergency_service.dart';

class MainController {

  final SensorManager sensorManager = SensorManager();
  final AnomalyEngine anomalyEngine = AnomalyEngine();
  final RecordingManager recordingManager = RecordingManager();

  bool isRecording = false;
  bool isHandlingEmergency = false;

  Function(String message)? onUIEvent;

  Future<void> start() async {

    await recordingManager.initializeCamera();

    anomalyEngine.onAnomalyDetected = (event) async {

      print("[Main] Anomaly detected: ${event.type}");

      if (!isRecording) {
        isRecording = true;
        await recordingManager.startRecording();
        Future.delayed(const Duration(milliseconds: 300), () {
          onUIEvent?.call("Auto recording started");
        });
      }

      if (event.severity == "EMERGENCY" && !isHandlingEmergency) {

        isHandlingEmergency = true;

        Future.delayed(const Duration(milliseconds: 300), () {
          onUIEvent?.call("Emergency detected");
        });

        if (!isRecording) {
          isRecording = true;
          await recordingManager.startRecording();
        }

        await Future.delayed(const Duration(seconds: 5));

        final path = await recordingManager.stopRecording();
        print("[Main] Auto-saved recording: $path");

        isRecording = false;

        await EmergencyService.triggerWithoutUI();

        await Future.delayed(const Duration(seconds: 15));

        isHandlingEmergency = false;
      }
    };

    sensorManager.onSensorData = (SensorData data) {
      anomalyEngine.processSensorData(data);
    };

    sensorManager.startSensorCollection();
  }

  void stop() {
    sensorManager.stopSensorCollection();
    recordingManager.dispose();
  }
}