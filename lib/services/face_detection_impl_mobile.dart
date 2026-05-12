import 'package:camera/camera.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import '../services/face_detection_service.dart';

class FaceDetectionImpl {
  final FaceMeshDetector _meshDetector =
      FaceMeshDetector(option: FaceMeshDetectorOptions.faceMesh);

  Future<List<FaceMesh>> processImage(
      CameraImage image, CameraController controller) async {
    final inputImage = FaceDetectionService.inputImageFromCameraImage(image, controller);
    if (inputImage == null) return [];
    return await _meshDetector.processImage(inputImage);
  }

  void dispose() {
    _meshDetector.close();
  }
}
