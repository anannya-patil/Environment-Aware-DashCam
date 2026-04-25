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

  Future<void> start() async {

    await recordingManager.initializeCamera();

    sensorManager.onSensorData = (SensorData data) async {

      final event = anomalyEngine.processSensorData(data);

      if (event != null) {

        print("[Main] Anomaly detected: ${event.type}");

        if (!isRecording) {
          isRecording = true;
          await recordingManager.startRecording();
        }

        if (event.severity == "EMERGENCY") {
          EmergencyService.triggerWithoutUI();
        }
      }
    };

    sensorManager.startSensorCollection();
  }

  void stop() {
    sensorManager.stopSensorCollection();
    recordingManager.dispose();
  }
}