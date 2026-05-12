import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'face_detection_impl_stub.dart'
    if (dart.library.io) 'face_detection_impl_mobile.dart'
    if (dart.library.html) 'face_detection_impl_web.dart'
    if (dart.library.js_interop) 'face_detection_impl_web.dart';

class FaceDetectionService {
  final FaceDetectionImpl _impl = FaceDetectionImpl();

  Future<List<dynamic>> processImage(
      CameraImage image, CameraController controller) async {
    return await _impl.processImage(image, controller);
  }

  void dispose() {
    _impl.dispose();
  }

  static InputImage? inputImageFromCameraImage(
      CameraImage image, CameraController controller) {
    final rotations = {
      0: InputImageRotation.rotation0deg,
      90: InputImageRotation.rotation90deg,
      180: InputImageRotation.rotation180deg,
      270: InputImageRotation.rotation270deg,
    };

    final rotation = rotations[controller.description.sensorOrientation];
    if (rotation == null) return null;

    InputImageFormat? format =
        InputImageFormatValue.fromRawValue(image.format.raw);

    // Fallback for cases where format is not recognized
    if (format == null) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        format = InputImageFormat.nv21;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        format = InputImageFormat.bgra8888;
      }
    }

    if (format == null) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }
}
