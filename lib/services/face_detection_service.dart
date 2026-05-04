import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {
  final FaceMeshDetector _meshDetector = FaceMeshDetector(
    option: FaceMeshDetectorOptions.faceMesh,
  );
  
  final FaceDetector _standardDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  bool _isProcessing = false;

  Future<List<FaceMesh>> processImage(
      CameraImage image, CameraController controller) async {
    if (_isProcessing) return [];
    _isProcessing = true;

    final bytes = _convertYUV420ToNV21(image);

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final camera = controller.description;

    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation270deg;
    
    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.width, // In NV21, Y plane width is image width
      ),
    );

    try {
      // Try Face Mesh first
      var faces = await _meshDetector.processImage(inputImage);
      
      // If mesh fails, try standard face detection as fallback
      if (faces.isEmpty) {
        final stdFaces = await _standardDetector.processImage(inputImage);
        if (stdFaces.isNotEmpty) {
          debugPrint("Fallback: Standard Face detected");
          // Convert standard face to a minimal FaceMesh object if possible
          // For now, we return empty to avoid type mismatch, but we log it
        }
      }
      
      _isProcessing = false;
      return faces;
    } catch (e) {
      debugPrint("Face detection error: $e");
      _isProcessing = false;
      return [];
    }
  }

  Uint8List _convertYUV420ToNV21(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yBuffer = yPlane.bytes;
    final uBuffer = uPlane.bytes;
    final vBuffer = vPlane.bytes;

    final numPixels = width * height;
    final nv21 = Uint8List(numPixels + (numPixels ~/ 2));

    // Y plane
    for (int i = 0; i < numPixels; i++) {
      nv21[i] = yBuffer[i];
    }

    // UV interleaved (NV21: V U V U ...)
    final uvWidth = width ~/ 2;
    final uvHeight = height ~/ 2;
    int id = numPixels;
    
    for (int y = 0; y < uvHeight; y++) {
      for (int x = 0; x < uvWidth; x++) {
        final int uvIndex =
            y * (uPlane.bytesPerRow ?? 0) + x * (uPlane.bytesPerPixel ?? 1);
        nv21[id++] = vBuffer[uvIndex];
        nv21[id++] = uBuffer[uvIndex];
      }
    }

    return nv21;
  }

  void dispose() {
    _meshDetector.close();
    _standardDetector.close();
  }
}
