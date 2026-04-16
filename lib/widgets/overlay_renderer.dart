import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:hand_landmarker/hand_landmarker.dart';

class OverlayRenderer extends StatefulWidget {
  final List<FaceMesh> faces;
  final List<Hand>? hands;
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
    Key? key,
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
  }) : super(key: key);

  @override
  State<OverlayRenderer> createState() => _OverlayRendererState();
}

class _OverlayRendererState extends State<OverlayRenderer> {
  // Low-pass filter state for Face
  double? sL_x, sL_y, sR_x, sR_y, sC_x, sC_y;
  double? sW, sH;

  // Low-pass filter state for Hand (Key landmarks)
  Map<int, Offset> sHandPoints = {};

  final double alpha = 0.3;

  double _smooth(double? oldVal, double newVal) {
    if (oldVal == null) return newVal;
    return oldVal * (1 - alpha) + newVal * alpha;
  }

  Offset _smoothOffset(int id, Offset newVal) {
    final old = sHandPoints[id];
    if (old == null) {
      sHandPoints[id] = newVal;
      return newVal;
    }
    final smoothed = Offset(
      old.dx * (1 - alpha) + newVal.dx * alpha,
      old.dy * (1 - alpha) + newVal.dy * alpha,
    );
    sHandPoints[id] = smoothed;
    return smoothed;
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

    // --- Live Camera: Rings / Bangles ---
    if (widget.activeCategory == 'Rings' ||
        widget.activeCategory == 'Bangles') {
      // If hand detected, use landmarks
      if (widget.hands != null && widget.hands!.isNotEmpty) {
        return _buildHandOverlays(screenSize, scaleX, scaleY, offsetX, offsetY,
            logicalWidth, logicalHeight);
      }
      // Fallback: show centered, draggable overlay
      return _buildFallbackHandOverlay(screenSize);
    }

    // --- Live Camera: Face categories ---
    if (widget.faces.isEmpty) return const SizedBox.shrink();

    List<Widget> overlays = [];
    for (var face in widget.faces) {
      if (face.points.length < 468) continue;

      sL_x = _smooth(sL_x, face.points[137].x.toDouble());
      sL_y = _smooth(sL_y, face.points[137].y.toDouble());
      sR_x = _smooth(sR_x, face.points[366].x.toDouble());
      sR_y = _smooth(sR_y, face.points[366].y.toDouble());
      sC_x = _smooth(sC_x, face.points[152].x.toDouble());
      sC_y = _smooth(sC_y, face.points[152].y.toDouble());
      sW = _smooth(sW, face.boundingBox.width.toDouble());
      sH = _smooth(sH, face.boundingBox.height.toDouble());

      final double dx = face.points[454].x - face.points[234].x;
      final double dy = face.points[454].y - face.points[234].y;
      final double dz = face.points[454].z - face.points[234].z;

      final double rotZ = atan2(dy, dx);
      final double rotY = atan2(dz, dx) * (180 / pi);
      final Matrix4 transform = Matrix4.rotationZ(rotZ);

      final double faceWidth = sW! * scaleX;
      final double faceHeight = sH! * scaleY;

      if (widget.activeCategory == 'Earrings') {
        final double earringSize = faceWidth * 0.38;
        final double inwardOffset = faceWidth * 0.11;

        final bool showRight = rotY > -75;
        final bool showLeft = rotY < 75;

        if (showRight) {
          double rawX = widget.isFrontCamera ? logicalWidth - sR_x! : sR_x!;
          double x = (rawX * scaleX) + offsetX + inwardOffset;
          double y = (sR_y! * scaleY) + offsetY - (faceHeight * 0.12);

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
          double rawX = widget.isFrontCamera ? logicalWidth - sL_x! : sL_x!;
          double x = (rawX * scaleX) + offsetX - inwardOffset;
          double y = (sL_y! * scaleY) + offsetY - (faceHeight * 0.12);

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
            widget.isFrontCamera ? logicalWidth - sC_x! : sC_x!;
        final double centerX = (chinXRaw * scaleX) + offsetX;
        final double neckY = (sC_y! * scaleY) + offsetY + (faceHeight * 0.18);
        final double width = faceWidth * 0.95;

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

  /// Fallback overlay for when hand detection is not detecting anything.
  /// Shows the jewellery at a sensible position and allows manual drag/pinch.
  Widget _buildFallbackHandOverlay(Size screenSize) {
    final bool isRing = widget.activeCategory == 'Rings';
    // Ring: upper-center screen (where fingers typically are when hand is shown)
    // Bangle: lower-center screen (where wrist typically is)
    final double size = isRing
        ? screenSize.width * 0.20 * widget.manualScale
        : screenSize.width * 0.42 * widget.manualScale;
    final double defaultTop = isRing
        ? screenSize.height * 0.28  // upper area = fingers
        : screenSize.height * 0.60; // lower area = wrist

    return Stack(
      children: [
        Positioned(
          left: (screenSize.width - size) / 2 + widget.manualOffset.dx,
          top: defaultTop + widget.manualOffset.dy,
          child: Image.memory(
            widget.activeJewelleryImage!,
            width: size,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildHandOverlays(
      Size screenSize,
      double scaleX,
      double scaleY,
      double offsetX,
      double offsetY,
      double logicalWidth,
      double logicalHeight) {
    List<Widget> overlays = [];
    final landmarks = widget.hands!.first.landmarks;

    if (widget.activeCategory == 'Rings') {
      // Place ring at middle of ring finger (between landmarks 13 and 14)
      final mid = _smoothOffset(
          14,
          Offset(
            (landmarks[13].x + landmarks[14].x) / 2,
            (landmarks[13].y + landmarks[14].y) / 2,
          ));

      final double rawX = widget.isFrontCamera
          ? (1.0 - mid.dx) * logicalWidth
          : mid.dx * logicalWidth;
      final double x = (rawX * scaleX) + offsetX;
      final double y = (mid.dy * logicalHeight * scaleY) + offsetY;

      // Finger angle for rotation
      final double dx = landmarks[14].x - landmarks[13].x;
      final double dy = landmarks[14].y - landmarks[13].y;
      final double angle = atan2(dy, dx) + (pi / 2);

      // Scale ring to finger width (distance between adjacent knuckles)
      final double fingerSpan =
          (landmarks[14].x - landmarks[10].x).abs() * logicalWidth * scaleX;
      final double ringWidth = (fingerSpan * 1.8).clamp(35.0, 100.0);

      overlays.add(Positioned(
        left: x - (ringWidth / 2) + widget.manualOffset.dx,
        top: y - (ringWidth * 0.3) + widget.manualOffset.dy,
        child: Transform.rotate(
          angle: angle,
          child: Transform.scale(
            scale: widget.manualScale,
            child: Image.memory(widget.activeJewelleryImage!,
                width: ringWidth, fit: BoxFit.contain),
          ),
        ),
      ));
    } else if (widget.activeCategory == 'Bangles') {
      // Place bangle at wrist
      final wrist = _smoothOffset(0, Offset(landmarks[0].x, landmarks[0].y));

      final double rawX = widget.isFrontCamera
          ? (1.0 - wrist.dx) * logicalWidth
          : wrist.dx * logicalWidth;
      final double x = (rawX * scaleX) + offsetX;
      final double y = (wrist.dy * logicalHeight * scaleY) + offsetY;

      // Wrist-to-palm angle
      final double dx = landmarks[9].x - landmarks[0].x;
      final double dy = landmarks[9].y - landmarks[0].y;
      final double angle = atan2(dy, dx) + (pi / 2);

      // Bangle width based on wrist span
      final double wristSpan =
          (landmarks[17].x - landmarks[1].x).abs() * logicalWidth * scaleX;
      final double bangleWidth = (wristSpan * 2.5).clamp(80.0, 220.0);

      overlays.add(Positioned(
        left: x - (bangleWidth / 2) + widget.manualOffset.dx,
        top: y - (bangleWidth * 0.15) + widget.manualOffset.dy,
        child: Transform.rotate(
          angle: angle,
          child: Transform.scale(
            scale: widget.manualScale,
            child: Image.memory(widget.activeJewelleryImage!,
                width: bangleWidth, fit: BoxFit.contain),
          ),
        ),
      ));
    }

    return Stack(children: overlays);
  }

  Widget _buildModelOverlays(Size screenSize) {
    if (widget.activeCategory == 'Rings') {
      // Ring finger mid-phalanx: roughly 32% down the screen on the hand model
      final double rSize = screenSize.width * 0.18 * widget.manualScale;
      return Stack(children: [
        Positioned(
          // Ring finger is slightly right of center on the hand model
          left: screenSize.width * 0.40 + widget.manualOffset.dx,
          top: screenSize.height * 0.36 + widget.manualOffset.dy,
          child: Image.memory(widget.activeJewelleryImage!,
              width: rSize, fit: BoxFit.contain),
        ),
      ]);
    } else if (widget.activeCategory == 'Bangles') {
      // Wrist: roughly 68% down the screen on the hand model
      final double bSize = screenSize.width * 0.40 * widget.manualScale;
      return Stack(children: [
        Positioned(
          left: (screenSize.width - bSize) / 2 + widget.manualOffset.dx,
          top: screenSize.height * 0.65 + widget.manualOffset.dy,
          child: Image.memory(widget.activeJewelleryImage!,
              width: bSize, fit: BoxFit.contain),
        ),
      ]);
    }

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
