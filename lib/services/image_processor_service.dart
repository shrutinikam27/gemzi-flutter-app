import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageProcessorService {
  /// Converts white background of an image to transparent using isolates.
  static Future<Uint8List?> makeWhiteBackgroundTransparent(
      Uint8List imageBytes) async {
    return compute(_processImage, imageBytes);
  }

  static Uint8List? _processImage(Uint8List imageBytes) {
    img.Image? decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) return null;

    // Create a NEW image with alpha channel for background removal
    img.Image newImage = img.Image(
        width: decodedImage.width, height: decodedImage.height, numChannels: 4);

    // Highly aggressive background removal
    for (final pixel in decodedImage) {
      final r = pixel.r;
      final g = pixel.g;
      final b = pixel.b;
      final a = pixel.a;

      // Calculate 'Whiteness' or 'Brightness'
      // Normal background is usually very bright (near 255) and very neutral (R~G~B)
      final double rD = r.toDouble();
      final double gD = g.toDouble();
      final double bD = b.toDouble();

      final double brightness = (rD + gD + bD) / 3;
      final double variance =
          (rD - gD).abs() + (gD - bD).abs() + (rD - bD).abs();

      // PROTECT Gold/Yellow/RoseGold (Jewellery tones)
      // Gold usually has R > G > B
      final bool isJewelleryTone = (r > b + 30) && (g > b + 10);

      // TARGET:
      // 1. Very bright pixels (White)
      // 2. High brightness with low variance (Greyish backgrounds)
      if (!isJewelleryTone && (brightness > 200 && variance < 30)) {
        newImage.setPixelRgba(pixel.x, pixel.y, r, g, b, 0); // Transparent
      } else if (brightness > 245) {
        newImage.setPixelRgba(pixel.x, pixel.y, r, g, b, 0); // Pure White
      } else {
        newImage.setPixelRgba(pixel.x, pixel.y, r, g, b, a); // Preserve
      }
    }

    return img.encodePng(newImage);
  }
}
