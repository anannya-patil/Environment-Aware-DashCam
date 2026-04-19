import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class RecordingManager {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  CameraController? get controller => _cameraController;

  // Initialize rear camera
  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();

      final rearCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      _cameraController = CameraController(
        rearCamera,
        ResolutionPreset.high,
        enableAudio: false, // 🔥 keep this OFF (prevents MediaRecorder crash)
      );

      await _cameraController!.initialize();

      print("[Camera] Initialized successfully");

    } catch (e) {
      print("[Camera Init Error] $e");
      rethrow;
    }
  }

  // Start recording
  Future<void> startRecording() async {
    try {
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        throw Exception("Camera not initialized");
      }

      if (_cameraController!.value.isRecordingVideo) {
        print("[Recording] Already recording");
        return;
      }

      print("[Recording] Preparing camera for video...");

      await _cameraController!.prepareForVideoRecording();

      await Future.delayed(const Duration(milliseconds: 200));

      print("[Recording] Starting video recording...");

      await _cameraController!.startVideoRecording();

      print("[Recording] Recording started");

    } catch (e) {
      print("[Start Recording Error] $e");
      rethrow;
    }
  }

  // Stop recording
  Future<String> stopRecording() async {
    try {
      if (_cameraController == null ||
          !_cameraController!.value.isRecordingVideo) {
        throw Exception("Recording not started");
      }

      print("[Recording] Stopping recording...");

      final XFile videoFile =
          await _cameraController!.stopVideoRecording();

      print("[Recording] File captured: ${videoFile.path}");

      final savedPath = await _saveVideoLocally(videoFile);

      return savedPath;

    } catch (e) {
      print("[Stop Recording Error] $e");
      rethrow;
    }
  }

  // ✅ SAFE SAVE (INTERNAL STORAGE — WILL WORK 100%)
  Future<String> _saveVideoLocally(XFile videoFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final fileName =
          "recording_${DateTime.now().millisecondsSinceEpoch}.mp4";

      final newPath = path.join(directory.path, fileName);

      await videoFile.saveTo(newPath);

      print("[Save] Saved internally: $newPath");

      return newPath;

    } catch (e) {
      print("[Save Error] $e");
      rethrow;
    }
  }

  // Dispose camera
  void dispose() {
    _cameraController?.dispose();
    print("[Camera] Disposed");
  }
}