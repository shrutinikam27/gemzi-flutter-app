import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

void main() {
  Directory dir = Directory('assets/auth');
  List<FileSystemEntity> files = dir.listSync();
  
  for (var file in files) {
    if (file is File && file.path.endsWith('.jpeg')) {
      print('Processing \${file.path}');
      Uint8List bytes = file.readAsBytesSync();
      img.Image? decoded = img.decodeImage(bytes);
      if (decoded == null) continue;
      
      img.Image newImage = img.Image(width: decoded.width, height: decoded.height, format: img.Format.uint8, numChannels: 4);

      for (int y = 0; y < decoded.height; y++) {
        for (int x = 0; x < decoded.width; x++) {
          final pixel = decoded.getPixel(x, y);
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;
          
          if (r > 210 && g > 210 && b > 210) {
            newImage.setPixelRgba(x, y, r, g, b, 0); 
          } else {
            num alpha = 255;
            if (pixel.length == 4) alpha = pixel.a;
            newImage.setPixelRgba(x, y, r, g, b, alpha);
          }
        }
      }
      
      String newPath = file.path.replaceAll('.jpeg', '.png');
      File(newPath).writeAsBytesSync(img.encodePng(newImage));
      print('Created \$newPath');
    }
  }
}
