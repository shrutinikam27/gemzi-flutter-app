import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:hand_landmarker/hand_landmarker.dart';

class HandDetectionService {
  HandLandmarkerPlugin? _handLandmarker;
  bool _isInitialized = false;
  bool _isProcessing = false;

  void initialize() {
    if (_isInitialized) return;
    try {
      _handLandmarker = HandLandmarkerPlugin.create(
        numHands: 1,
        minHandDetectionConfidence: 0.3,
        delegate: HandLandmarkerDelegate.cpu, // CPU is more reliable across devices
      );
      _isInitialized = true;
      debugPrint("HandLandmarker initialized successfully");
    } catch (e) {
      debugPrint("HandLandmarker init error: $e");
      _isInitialized = false;
    }
  }

  List<Hand>? processImage(CameraImage image, CameraController controller) {
    if (!_isInitialized || _handLandmarker == null) {
      initialize();
      if (!_isInitialized) return null;
    }
    if (_isProcessing) return null;
    _isProcessing = true;

    try {
      final result = _handLandmarker!.detect(
        image,
        controller.description.sensorOrientation,
      );
      if (result.isNotEmpty) {
        debugPrint("Hand detected! Count: ${result.length}");
      }
      _isProcessing = false;
      return result;
    } catch (e) {
      debugPrint("Hand detection error: $e");
      _isProcessing = false;
      return null;
    }
  }

  void dispose() {
    if (_isInitialized && _handLandmarker != null) {
      try {
        _handLandmarker!.dispose();
      } catch (_) {}
    }
  }
}
