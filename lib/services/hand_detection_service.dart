import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

// Removed incompatible hand_landmarker library for Web support
// import 'package:hand_landmarker/hand_landmarker.dart';

class HandDetectionService {
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    debugPrint("HandDetectionService: Stub initialized (Hand Tracking is disabled for Web compatibility)");
    _isInitialized = true;
  }

  List<dynamic>? processImage(CameraImage image, CameraController controller) {
    // Return empty results on Web or when disabled
    return null;
  }

  void dispose() {
    debugPrint("HandDetectionService disposed");
  }
}
