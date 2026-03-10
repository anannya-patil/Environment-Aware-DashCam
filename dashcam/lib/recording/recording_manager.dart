import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class RecordingManager {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  CameraController? get controller => _cameraController;

  // Initialize rear camera
  Future<void> initializeCamera() async {
    _cameras = await availableCameras();

    final rearCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );

    _cameraController = CameraController(
      rearCamera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    await _cameraController!.initialize();
  }

  // Start recording
  Future<void> startRecording() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized) {
      throw Exception("Camera not initialized");
    }

    if (_cameraController!.value.isRecordingVideo) {
      return;
    }

    await _cameraController!.startVideoRecording();
  }

  // Stop recording
  Future<String> stopRecording() async {
    if (_cameraController == null ||
        !_cameraController!.value.isRecordingVideo) {
      throw Exception("Recording not started");
    }

    final XFile videoFile =
        await _cameraController!.stopVideoRecording();

    final savedPath = await _saveVideoLocally(videoFile);

    return savedPath;
  }

  // Save video in Dashcam folder
  Future<String> _saveVideoLocally(XFile videoFile) async {
    final directory = await getApplicationDocumentsDirectory();

    final dashcamDir =
        Directory(path.join(directory.path, "Dashcam", "recordings"));

    if (!await dashcamDir.exists()) {
      await dashcamDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final fileName = "recording_$timestamp.mp4";

    final newPath = path.join(dashcamDir.path, fileName);

    final savedFile = await File(videoFile.path).copy(newPath);

    return savedFile.path;
  }

  // Dispose camera
  void dispose() {
    _cameraController?.dispose();
  }
}