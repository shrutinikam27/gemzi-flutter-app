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

    // Check if the image already has meaningful transparency
    bool hasInitialTransparency = false;
    if (decodedImage.numChannels == 4) {
      for (final pixel in decodedImage) {
        if (pixel.a < 250) {
          hasInitialTransparency = true;
          break;
        }
      }
    }

    // If it already has transparency, just return the original bytes (encoded as PNG)
    if (hasInitialTransparency) {
      return imageBytes;
    }

    // Create a NEW image with alpha channel for background removal
    img.Image newImage = img.Image(
        width: decodedImage.width, height: decodedImage.height, numChannels: 4);

    for (final pixel in decodedImage) {
      final r = pixel.r;
      final g = pixel.g;
      final b = pixel.b;
      final a = pixel.a;

      final double rD = r.toDouble();
      final double gD = g.toDouble();
      final double bD = b.toDouble();

      final double brightness = (rD + gD + bD) / 3;
      final double variance =
          (rD - gD).abs() + (gD - bD).abs() + (rD - bD).abs();

      // PROTECT Jewellery: Gold, Silver, Diamonds, Pearls
      // Gold: R > B, G > B
      // Silver/Diamond/Pearl: High brightness, but we must be careful not to erase the subject
      final bool isGoldTone = (r > b + 15) && (g > b + 5);
      
      // Target background-like pixels. JPEG backgrounds are often off-white (220+) 
      // with slight color variance due to compression artifacts.
      if (!isGoldTone && brightness > 225 && variance < 25) {
        newImage.setPixelRgba(pixel.x, pixel.y, r, g, b, 0); // Transparent
      } else if (brightness > 245) {
        newImage.setPixelRgba(pixel.x, pixel.y, r, g, b, 0); // Absolute white
      } else {
        newImage.setPixelRgba(pixel.x, pixel.y, r, g, b, a); // Preserve
      }
    }

    return img.encodePng(newImage);
  }
}
