import 'package:camera/camera.dart';
import 'dart:io';

class CameraService {
  CameraController? controller;
  List<CameraDescription>? _cameras;
  CameraDescription? _currentCamera;
  Function(CameraImage)? onImage;
  bool isInitialized = false;

  Future<void> initializeCamera(CameraLensDirection direction, Function(CameraImage) onImageStream) async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;

    _currentCamera = _cameras?.firstWhere(
      (cam) => cam.lensDirection == direction,
      orElse: () => _cameras!.first,
    );
    onImage = onImageStream;
    
    if (_currentCamera != null) {
      await _startController(_currentCamera!);
    }
  }

  Future<void> _startController(CameraDescription camera) async {
    controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
    );
    await controller?.initialize();
    isInitialized = true;
    controller?.startImageStream((image) {
      if (onImage != null) onImage!(image);
    });
  }

  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    
    CameraLensDirection newDirection = _currentCamera!.lensDirection == CameraLensDirection.front 
      ? CameraLensDirection.back 
      : CameraLensDirection.front;

    await switchToDirection(newDirection);
  }

  Future<void> switchToDirection(CameraLensDirection direction) async {
    if (_cameras == null || _cameras!.isEmpty) return;
    if (_currentCamera?.lensDirection == direction) return;

    _currentCamera = _cameras?.firstWhere(
      (cam) => cam.lensDirection == direction,
      orElse: () => _cameras!.first,
    );

    if (_currentCamera != null) {
      isInitialized = false;
      await controller?.stopImageStream();
      await controller?.dispose();
      await _startController(_currentCamera!);
    }
  }

  Future<void> dispose() async {
    isInitialized = false;
    await controller?.stopImageStream();
    await controller?.dispose();
  }
}
