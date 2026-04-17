import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

void main() async {
  // Read an asset image
  File file = File('assets/auth/emeraldearrings.jpeg'); // Or any necklace
  if (!file.existsSync()) {
    print("File not found");
    return;
  }
  Uint8List bytes = file.readAsBytesSync();
  img.Image? decoded = img.decodeImage(bytes);
  if (decoded == null) {
    print("Could not decode");
    return;
  }
  
  print("hasAlpha before: ${decoded.hasAlpha}");
  print("numChannels before: ${decoded.numChannels}");
  
  if (!decoded.hasAlpha) {
    // We need to convert it to a format with an alpha channel
    // In image ^4.x, convert creates a copy with the appropriate channels.
    // decoded = decoded.convert(numChannels: 4); // Wait, we can test the API.
  }
}
