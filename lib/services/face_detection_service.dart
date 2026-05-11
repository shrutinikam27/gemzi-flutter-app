import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
// import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {
  // Use dynamic or stubs for Web to avoid importing ML Kit
  final dynamic _meshDetector = null;
  final dynamic _standardDetector = null;

  bool _isProcessing = false;

  Future<List<dynamic>> processImage(
      CameraImage image, CameraController controller) async {
    // Face detection is not supported on Web with ML Kit
    return [];
  }

  void dispose() {
    debugPrint("FaceDetectionService disposed");
  }
}
