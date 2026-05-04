import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';

class OverlayRenderer extends StatefulWidget {
  final List<FaceMesh> faces;
  final List<dynamic>? hands; // Kept as dynamic to avoid breaking TryOnScreen for now, though it's always empty
  final Size expectedImageSize;
  final Uint8List? activeJewelleryImage;
  final String? activeJewelleryPath;
  final String activeCategory;
  final bool isFrontCamera;
  final bool isModelMode;
  final bool isEditMode;
  final Offset manualOffset;
  final double manualScale;
  final double manualRotation;

  const OverlayRenderer({
    super.key,
    required this.faces,
    this.hands,
    required this.expectedImageSize,
    required this.activeJewelleryImage,
    this.activeJewelleryPath,
    required this.activeCategory,
    required this.isFrontCamera,
    this.isModelMode = false,
    this.isEditMode = false,
    this.manualOffset = Offset.zero,
    this.manualScale = 1.0,
    this.manualRotation = 0.0,
  });

  @override
  State<OverlayRenderer> createState() => _OverlayRendererState();
}

class _OverlayRendererState extends State<OverlayRenderer> {
  // Low-pass filter state for Face
  double? slX, slY, srX, srY, scX, scY;
  double? sw, sh;

  final double alpha = 0.3;

  double _smooth(double? oldVal, double newVal) {
    if (oldVal == null) return newVal;
    return oldVal * (1 - alpha) + newVal * alpha;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activeJewelleryImage == null ||
        (widget.expectedImageSize.isEmpty && !widget.isModelMode)) {
      return const SizedBox.shrink();
    }

    final Size screenSize = MediaQuery.of(context).size;

    double scaleX, scaleY, offsetX, offsetY;

    final double expectedW = widget.expectedImageSize.width;
    final double expectedH = widget.expectedImageSize.height;
    final double logicalWidth = min(expectedW, expectedH);
    final double logicalHeight = max(expectedW, expectedH);

    if (widget.isModelMode) {
      scaleX = 1.0;
      scaleY = 1.0;
      offsetX = 0;
      offsetY = 0;
    } else {
      final double scale =
          (screenSize.width / logicalWidth > screenSize.height / logicalHeight)
              ? screenSize.width / logicalWidth
              : screenSize.height / logicalHeight;

      scaleX = scale;
      scaleY = scale;
      offsetX = (screenSize.width - logicalWidth * scale) / 2;
      offsetY = (screenSize.height - logicalHeight * scale) / 2;
    }

    // --- Model Mode ---
    if (widget.isModelMode) {
      return _buildModelOverlays(screenSize);
    }

    // --- Live Camera: Face categories ---
    if (widget.faces.isEmpty) return const SizedBox.shrink();

    List<Widget> overlays = [];
    for (var face in widget.faces) {
      if (face.points.length < 468) continue;

      // Indices for ear areas and chin
      final leftEar = face.points[132];
      final rightEar = face.points[361];
      final chin = face.points[152];

      slX = _smooth(slX, leftEar.x.toDouble());
      slY = _smooth(slY, leftEar.y.toDouble());
      srX = _smooth(srX, rightEar.x.toDouble());
      srY = _smooth(srY, rightEar.y.toDouble());
      scX = _smooth(scX, chin.x.toDouble());
      scY = _smooth(scY, chin.y.toDouble());
      sw = _smooth(sw, face.boundingBox.width.toDouble());
      sh = _smooth(sh, face.boundingBox.height.toDouble());

      final double dx = face.points[454].x - face.points[234].x;
      final double dy = face.points[454].y - face.points[234].y;
      final double dz = face.points[454].z - face.points[234].z;

      final double rotZ = atan2(dy, dx);
      final double rotY = atan2(dz, dx) * (180 / pi);
      final Matrix4 transform = Matrix4.rotationZ(rotZ);

      final double faceWidth = sw! * scaleX;
      final double faceHeight = sh! * scaleY;

      if (widget.activeCategory == 'Earrings') {
        final double earringSize = faceWidth * 0.38;
        final double inwardOffset = faceWidth * 0.11;

        final bool showRight = rotY > -75;
        final bool showLeft = rotY < 75;

        if (showRight) {
          double rawX = widget.isFrontCamera ? logicalWidth - srX! : srX!;
          double x = (rawX * scaleX) + offsetX + inwardOffset;
          double y = (srY! * scaleY) + offsetY - (faceHeight * 0.10);

          overlays.add(Positioned(
            left: x - (earringSize / 2) + widget.manualOffset.dx,
            top: y + widget.manualOffset.dy,
            child: Transform.scale(
                scale: widget.manualScale,
                child: Transform(
                    alignment: Alignment.topCenter,
                    transform: transform,
                    child: _buildEarringPart(
                        widget.activeJewelleryImage!, earringSize, false))),
          ));
        }

        if (showLeft) {
          double rawX = widget.isFrontCamera ? logicalWidth - slX! : slX!;
          double x = (rawX * scaleX) + offsetX - inwardOffset;
          double y = (slY! * scaleY) + offsetY - (faceHeight * 0.12);

          overlays.add(Positioned(
            left: x - (earringSize / 2) + widget.manualOffset.dx,
            top: y + widget.manualOffset.dy,
            child: Transform.scale(
                scale: widget.manualScale,
                child: Transform(
                    alignment: Alignment.topCenter,
                    transform: transform,
                    child: _buildEarringPart(
                        widget.activeJewelleryImage!, earringSize, true))),
          ));
        }
      } else if (widget.activeCategory == 'Necklaces') {
        final double chinXRaw =
            widget.isFrontCamera ? logicalWidth - scX! : scX!;
        final double centerX = (chinXRaw * scaleX) + offsetX;
        final double neckY = (scY! * scaleY) + offsetY + (faceHeight * 0.15);
        final double width = faceWidth * 0.90;

        overlays.add(Positioned(
          left: centerX - (width / 2) + widget.manualOffset.dx,
          top: neckY + widget.manualOffset.dy,
          child: Transform.scale(
              scale: widget.manualScale,
              child: Transform(
                  alignment: Alignment.topCenter,
                  transform: transform,
                  child: Image.memory(widget.activeJewelleryImage!,
                      width: width, fit: BoxFit.contain))),
        ));
      }
    }
    return Stack(children: overlays);
  }

  Widget _buildModelOverlays(Size screenSize) {
    final double necklaceY = screenSize.height * 0.53 + widget.manualOffset.dy;
    final double earringsY = screenSize.height * 0.43 + widget.manualOffset.dy;

    if (widget.activeCategory == 'Earrings') {
      final double eSize = screenSize.width * 0.15 * widget.manualScale;
      return Stack(children: [
        Positioned(
            left:
                screenSize.width * 0.38 - (eSize / 2) + widget.manualOffset.dx,
            top: earringsY,
            child:
                _buildEarringPart(widget.activeJewelleryImage!, eSize, false)),
        Positioned(
            left:
                screenSize.width * 0.62 - (eSize / 2) + widget.manualOffset.dx,
            top: earringsY,
            child:
                _buildEarringPart(widget.activeJewelleryImage!, eSize, true)),
      ]);
    } else if (widget.activeCategory == 'Necklaces') {
      final double width = screenSize.width * 0.45 * widget.manualScale;
      return Stack(children: [
        Positioned(
            left: (screenSize.width - width) / 2 + widget.manualOffset.dx,
            top: necklaceY,
            child: Image.memory(widget.activeJewelleryImage!,
                width: width, fit: BoxFit.contain)),
      ]);
    }
    return const SizedBox.shrink();
  }

  Widget _buildEarringPart(Uint8List image, double size, bool isLeftPart) {
    return ClipRect(
      child: Align(
        alignment: isLeftPart ? Alignment.centerLeft : Alignment.centerRight,
        widthFactor: 0.5,
        child: Image.memory(image,
            width: size * 2, height: size, fit: BoxFit.contain),
      ),
    );
  }
}
