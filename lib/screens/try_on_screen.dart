import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';
import 'package:screenshot/screenshot.dart';

import '../services/camera_service.dart';
import '../services/face_detection_service.dart';
import '../services/image_processor_service.dart';
import '../widgets/overlay_renderer.dart';

class TryOnScreen extends StatefulWidget {
  const TryOnScreen({super.key});

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen> {
  final CameraService _cameraService = CameraService();
  final FaceDetectionService _faceDetectionService = FaceDetectionService();
  final ScreenshotController _screenshotController = ScreenshotController();

  // --- Modes ---
  bool isModelMode = false;
  bool isCaptured = false;
  XFile? capturedFile;

  // --- AR State ---
  List<FaceMesh> faces = [];
  bool isBusy = false;
  int frameCount = 0;
  Size? cameraImageSize;
  String distanceMessage = "";

  // --- Jewellery Selection ---
  String activeCategory = 'Necklaces';
  Uint8List? processingImage;
  String? processingImageName;

  // --- Manual Adjustment ---
  Offset manualOffset = Offset.zero;
  double manualScale = 1.0;
  double manualRotation = 0.0;

  final Color richGold = const Color(0xFFD4AF37);
  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);

  final List<String> categories = ['Necklaces', 'Earrings'];

  final Map<String, List<Map<String, String>>> categoryItems = {
    'Earrings': [
      {"name": "Emerald", "image": "assets/auth/earringnew.png"},
      {"name": "Pearl", "image": "assets/auth/earringnew1.png"},
    ],
    'Necklaces': [
      {"name": "Gold Neck", "image": "assets/auth/necklacenew.png"},
      {"name": "Pearl Neck", "image": "assets/auth/necklacenew1.png"},
      {"name": "Daimond Neck", "image": "assets/auth/necklacenew2.png"},
    ],
  };

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndInitialize();
    _selectJewellery(categoryItems['Necklaces']![0]['image']!);
  }

  String? _initError;

  Future<void> _checkPermissionsAndInitialize() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        await _cameraService.initializeCamera(
            CameraLensDirection.front, _processCameraImage);
        if (mounted) setState(() { _initError = null; });
      } else {
        setState(() {
          _initError = "Camera permission denied. Please enable it in settings.";
        });
      }
    } catch (e) {
      debugPrint("Init error: $e");
      setState(() {
        _initError = "Failed to initialize camera: $e";
      });
    }
  }

  void _processCameraImage(CameraImage image) async {
    frameCount++;
    if (frameCount % 2 != 0) return;

    final controller = _cameraService.controller;
    if (isBusy ||
        isModelMode ||
        isCaptured ||
        controller == null ||
        !controller.value.isInitialized) {
      return;
    }
    isBusy = true;

    if (cameraImageSize == null) {
      if (mounted) {
        setState(() {
          cameraImageSize =
              Size(image.width.toDouble(), image.height.toDouble());
        });
      }
    }

    try {
      final detectedFaces =
          await _faceDetectionService.processImage(image, controller);

      String newGuidance = "";
      if (detectedFaces.isNotEmpty) {
        final face = detectedFaces.first;
        final double faceW = face.boundingBox.width;
        final double screenW =
            cameraImageSize!.width < cameraImageSize!.height
                ? cameraImageSize!.width
                : cameraImageSize!.height;

        final double ratio = faceW / screenW;
        if (ratio < 0.35) {
          newGuidance = "Move Closer";
        } else if (ratio > 0.65) {
          newGuidance = "Move Further Away";
        } else {
          newGuidance = "Perfect";
        }
      }

      if (mounted) {
        setState(() {
          faces = detectedFaces;
          distanceMessage = newGuidance;
        });
      }
    } catch (e) {
      debugPrint("Detection error: $e");
    } finally {
      isBusy = false;
    }
  }

  Future<void> _selectJewellery(String assetPath) async {
    if (processingImageName == assetPath) return;

    setState(() {
      processingImageName = assetPath;
      processingImage = null;
    });

    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final transparentImage =
          await ImageProcessorService.makeWhiteBackgroundTransparent(bytes);

      if (mounted) {
        setState(() {
          processingImage = transparentImage;
        });
      }
    } catch (e) {
      debugPrint("Error processing image: $e");
    }
  }

  Future<void> _toggleMode(bool toModel) async {
    if (toModel == isModelMode) return;
    setState(() {
      isModelMode = toModel;
      isCaptured = false;
      capturedFile = null;
      faces = [];
      manualOffset = Offset.zero;
      manualScale = 1.0;
      manualRotation = 0.0;
    });
  }

  Future<void> _capturePhoto() async {
    final controller = _cameraService.controller;
    if (isModelMode || controller == null || !controller.value.isInitialized) {
      return;
    }
    try {
      await controller.pausePreview();
      setState(() {
        isCaptured = true;
      });
    } catch (e) {
      debugPrint("Capture error: $e");
    }
  }

  Future<void> _saveToGallery() async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          _showToast("Gallery access denied.");
          return;
        }
      }

      final Uint8List? imageBytes = await _screenshotController.capture(
          delay: const Duration(milliseconds: 10));
      if (imageBytes != null) {
        await Gal.putImageBytes(imageBytes);
        _showToast("Saved to your Gallery!");
      } else {
        _showToast("Capture failed.");
      }
    } catch (e) {
      debugPrint("Save error: $e");
      _showToast("Error saving image.");
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _faceDetectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasCamera =
        _cameraService.isInitialized && _cameraService.controller != null;

    Widget previewWidget = const Center(child: CircularProgressIndicator());

    if (isModelMode) {
      const String modelAsset = 'assets/auth/model.png';

      previewWidget = Image.asset(modelAsset,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[900],
              child: Center(
                  child: Text("$modelAsset Not Found",
                      style: const TextStyle(color: Colors.white)))));
    } else if (hasCamera) {
      final controller = _cameraService.controller!;
      final size = controller.value.previewSize;
      if (size != null) {
        previewWidget = SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.height,
              height: size.width,
              child: CameraPreview(controller),
            ),
          ),
        );
      } else {
        previewWidget = CameraPreview(controller);
      }
    } else if (_initError != null) {
      previewWidget = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                _initError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkPermissionsAndInitialize,
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Elegant Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [darkBg, surfaceDark, Colors.black],
              ),
            ),
          ),
          Screenshot(
            controller: _screenshotController,
            child: Stack(
              fit: StackFit.expand,
              children: [
                previewWidget,
                if (hasCamera || isModelMode) _buildOverlayLayer(),
              ],
            ),
          ),
          _buildTopUI(),
          _buildGuidanceMessage(),
          _buildBottomUI(),
        ],
      ),
    );
  }

  Widget _buildGuidanceMessage() {
    if (distanceMessage.isEmpty || isCaptured || isModelMode) {
      return const SizedBox.shrink();
    }

    final bool isPerfect = distanceMessage == "Perfect";

    return Positioned(
      top: 130,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
              color: isPerfect
                  ? Colors.green.withValues(alpha: 0.8)
                  : Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: isPerfect ? Colors.greenAccent : Colors.white54,
                  width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ]),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox.shrink(),
              Text(
                distanceMessage,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _baseScale = 1.0;

  Widget _buildOverlayLayer() {
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          manualOffset = Offset.zero;
          manualScale = 1.0;
          manualRotation = 0.0;
        });
      },
      onScaleStart: (details) {
        _baseScale = manualScale;
      },
      onScaleUpdate: (details) {
        setState(() {
          manualOffset += details.focalPointDelta;
          if (details.scale != 1.0) {
            manualScale = (_baseScale * details.scale).clamp(0.2, 4.0);
          }
          if (details.rotation != 0.0) {
            manualRotation += details.rotation;
          }
          final size = MediaQuery.of(context).size;
          manualOffset = Offset(
            manualOffset.dx.clamp(-size.width * 0.8, size.width * 0.8),
            manualOffset.dy.clamp(-size.height * 0.8, size.height * 0.8),
          );
        });
      },
      child: Container(
        color: Colors.transparent,
        child: OverlayRenderer(
          faces: faces,
          hands: const [],
          expectedImageSize: cameraImageSize ?? Size.zero,
          activeJewelleryImage: processingImage,
          activeJewelleryPath: processingImageName,
          activeCategory: activeCategory,
          isFrontCamera: _cameraService.controller?.description.lensDirection ==
              CameraLensDirection.front,
          isModelMode: isModelMode,
          isEditMode: isCaptured,
          manualOffset: manualOffset,
          manualScale: manualScale,
          manualRotation: manualRotation,
        ),
      ),
    );
  }

  Widget _buildTopUI() {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Color(0xFFD4AF37), size: 28),
                  onPressed: () => Navigator.pop(context)),
              _buildModeToggle(),
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      width: 200,
      height: 40,
      decoration: BoxDecoration(
          color: const Color(0xFF4A3728).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          _modeButton("Camera", !isModelMode, () async {
            if (isCaptured) {
              await _cameraService.controller?.resumePreview();
              setState(() => isCaptured = false);
            }
            _toggleMode(false);
          }),
          _modeButton("Model", isModelMode, () => _toggleMode(true)),
        ],
      ),
    );
  }

  Widget _modeButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: active ? richGold : Colors.transparent,
              borderRadius: BorderRadius.circular(20)),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  color: active ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildBottomUI() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _circleButton(
                  Icons.flip_camera_ios, () => _cameraService.switchCamera()),
              const SizedBox(width: 40),
              _captureActionButton(),
              const SizedBox(width: 40),
              _circleButton(Icons.download, _saveToGallery),
            ],
          ),
          const SizedBox(height: 30),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: categories.map((cat) => _categoryTab(cat)).toList()),
          ),
          const SizedBox(height: 15),
          _buildItemCarousel(),
        ],
      ),
    );
  }

  Widget _buildItemCarousel() {
    final items = categoryItems[activeCategory] ?? [];
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final bool isSelected = processingImageName == item['image'];
          return GestureDetector(
            onTap: () => _selectJewellery(item['image']!),
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected ? richGold : Colors.white24, width: 2),
                image: DecorationImage(
                    image: AssetImage(item['image']!), fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _categoryTab(String cat) {
    bool active = activeCategory == cat;
    return GestureDetector(
      onTap: () {
        setState(() {
          activeCategory = cat;
          faces = [];
          distanceMessage = "";
          manualOffset = Offset.zero;
          manualScale = 1.0;
        });
        _selectJewellery(categoryItems[cat]![0]['image']!);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Text(cat,
            style: TextStyle(
                color: active ? richGold : const Color(0xFF8B7355),
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
              color: Colors.white24, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white)),
    );
  }

  Widget _captureActionButton() {
    return GestureDetector(
      onTap: isCaptured
          ? () async {
              await _cameraService.controller?.resumePreview();
              setState(() => isCaptured = false);
            }
          : _capturePhoto,
      child: Container(
        width: 75,
        height: 75,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4)),
        child: Container(
            decoration: BoxDecoration(
                color: isCaptured ? richGold : Colors.black12,
                shape: BoxShape.circle),
            child:
                Icon(isCaptured ? Icons.refresh : null, color: Colors.black)),
      ),
    );
  }
}
