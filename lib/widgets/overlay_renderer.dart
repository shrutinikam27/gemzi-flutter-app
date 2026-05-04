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

  // Low-pass filter state for Hand (Key landmarks)
  Map<int, Offset> sHandPoints = {};
  List<dynamic>? lastKnownLandmarks;
  int lostDetectionFrames = 0;
  final int maxLostFrames = 10; // Keep item on hand for ~10 frames after losing tracking

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
      
      bool hasDetection = widget.hands != null && widget.hands!.isNotEmpty;
      
      if (hasDetection) {
        // If this is a fresh detection, start at the finger tip for a "sliding in" effect
        if (lastKnownLandmarks == null || lostDetectionFrames >= maxLostFrames) {
          final landmarks = widget.hands!.first.landmarks;
          // Landmark 16 is Ring finger TIP
          for (int i = 0; i < landmarks.length; i++) {
            sHandPoints[i] = Offset(landmarks[i].x, landmarks[i].y);
          }
          // Specifically for Rings, set the smoothing target to the tip first
          if (widget.activeCategory == 'Rings') {
             sHandPoints[14] = Offset(landmarks[16].x, landmarks[16].y);
          }
        }
        
        lastKnownLandmarks = widget.hands!.first.landmarks;
        lostDetectionFrames = 0;
      } else {
        lostDetectionFrames++;
      }

      // If we have current detection OR recent "sticky" detection
      if (hasDetection || (lastKnownLandmarks != null && lostDetectionFrames < maxLostFrames)) {
        return _buildHandOverlays(screenSize, scaleX, scaleY, offsetX, offsetY,
            logicalWidth, logicalHeight, lastKnownLandmarks!);
      }
      
      // Fallback: show centered, draggable overlay
      return _buildFallbackHandOverlay(screenSize);
    }

    // --- Live Camera: Face categories ---
    if (widget.faces.isEmpty) return const SizedBox.shrink();

    List<Widget> overlays = [];
    for (var face in widget.faces) {
      if (face.points.length < 468) continue;

      slX = _smooth(slX, face.points[137].x.toDouble());
      slY = _smooth(slY, face.points[137].y.toDouble());
      srX = _smooth(srX, face.points[366].x.toDouble());
      srY = _smooth(srY, face.points[366].y.toDouble());
      scX = _smooth(scX, face.points[152].x.toDouble());
      scY = _smooth(scY, face.points[152].y.toDouble());
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
          double y = (srY! * scaleY) + offsetY - (faceHeight * 0.12);

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
        final double neckY = (scY! * scaleY) + offsetY + (faceHeight * 0.18);
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
      double logicalHeight,
      List<dynamic> landmarks) {
    List<Widget> overlays = [];

    if (widget.activeCategory == 'Rings') {
      // Place ring on the ring finger proximal phalanx (between MCP and PIP)
      // Landmarks: 13 (MCP), 14 (PIP), 16 (TIP for starting point)
      final ringFingerBase = landmarks[13];
      final ringFingerJoint = landmarks[14];
      
      // Target is exactly in the middle of the phalanx (50/50)
      final targetX = (ringFingerBase.x + ringFingerJoint.x) / 2;
      final targetY = (ringFingerBase.y + ringFingerJoint.y) / 2;

      final midPoint = _smoothOffset(14, Offset(targetX, targetY));

      final double rawX = widget.isFrontCamera
          ? (1.0 - midPoint.dx) * logicalWidth
          : midPoint.dx * logicalWidth;
      final double x = (rawX * scaleX) + offsetX;
      final double y = (midPoint.dy * logicalHeight * scaleY) + offsetY;

      // Finger angle calculation
      final double dx = ringFingerJoint.x - ringFingerBase.x;
      final double dy = ringFingerJoint.y - ringFingerBase.y;
      final double angle = atan2(dy, dx) + (pi / 2);

      // Scale ring based on finger length
      final double fingerLength = sqrt(pow(dx, 2) + pow(dy, 2)) * logicalHeight * scaleY;
      final double ringWidth = (fingerLength * 1.0).clamp(35.0, 85.0);

      overlays.add(Positioned(
        left: x - (ringWidth / 2) + widget.manualOffset.dx,
        top: y - (ringWidth * 0.25) + widget.manualOffset.dy, // Adjusted to set correctly
        child: Transform.rotate(
          angle: angle + widget.manualRotation,
          child: Transform.scale(
            scale: widget.manualScale,
            child: Image.memory(widget.activeJewelleryImage!,
                width: ringWidth, fit: BoxFit.contain),
          ),
        ),
      ));
    } else if (widget.activeCategory == 'Bangles') {
      // Place bangle at the wrist/lower palm area
      // Landmarks: 0 (Wrist), 9 (Middle finger MCP)
      final wristPoint = landmarks[0];
      final palmPoint = landmarks[9];
      
      // Move slightly up from wrist towards palm
      final targetPoint = _smoothOffset(0, Offset(
        wristPoint.x * 0.8 + palmPoint.x * 0.2,
        wristPoint.y * 0.8 + palmPoint.y * 0.2,
      ));

      final double rawX = widget.isFrontCamera
          ? (1.0 - targetPoint.dx) * logicalWidth
          : targetPoint.dx * logicalWidth;
      final double x = (rawX * scaleX) + offsetX;
      final double y = (targetPoint.dy * logicalHeight * scaleY) + offsetY;

      // Arm/Wrist angle
      final double dx = palmPoint.x - wristPoint.x;
      final double dy = palmPoint.y - wristPoint.y;
      final double angle = atan2(dy, dx) + (pi / 2);

      // Bangle width based on wrist-to-pinky span
      // Landmarks: 1 (Thumb CMC), 17 (Pinky MCP)
      final double wristWidth = sqrt(
        pow(landmarks[17].x - landmarks[1].x, 2) + 
        pow(landmarks[17].y - landmarks[1].y, 2)
      ) * logicalWidth * scaleX;
      
      final double bangleWidth = (wristWidth * 1.8).clamp(100.0, 250.0);

      overlays.add(Positioned(
        left: x - (bangleWidth / 2) + widget.manualOffset.dx,
        top: y - (bangleWidth * 0.2) + widget.manualOffset.dy,
        child: Transform.rotate(
          angle: angle + widget.manualRotation,
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
