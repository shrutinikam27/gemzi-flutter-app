import 'package:camera/camera.dart';
import 'package:hand_landmarker/hand_landmarker.dart';

class HandDetectionImpl {
  HandLandmarkerPlugin? _plugin;
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    try {
      _plugin = HandLandmarkerPlugin.create();
      _isInitialized = true;
    } catch (e) {
      print("Error initializing hand landmarker: $e");
    }
  }

  List<Hand>? processImage(CameraImage image, CameraController controller) {
    if (!_isInitialized || _plugin == null) return null;
    
    try {
      // The plugin returns List<Hand>? where each Hand has a landmarks property
      final results = _plugin!.detect(image, controller.description.sensorOrientation);
      return results;
    } catch (e) {
      print("Error detecting hands: $e");
      return null;
    }
  }

  void dispose() {
    _plugin?.dispose();
  }
}
