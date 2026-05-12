import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'hand_detection_impl_stub.dart'
    if (dart.library.io) 'hand_detection_impl_mobile.dart'
    if (dart.library.html) 'hand_detection_impl_web.dart'
    if (dart.library.js_interop) 'hand_detection_impl_web.dart';

class HandDetectionService {
  final HandDetectionImpl _impl = HandDetectionImpl();

  void initialize() {
    _impl.initialize();
  }

  List<dynamic>? processImage(CameraImage image, CameraController controller) {
    return _impl.processImage(image, controller);
  }

  void dispose() {
    _impl.dispose();
  }
}
