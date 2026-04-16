import 'dart:io';

void main() {
  File file = File('pubspec.yaml');
  String contents = file.readAsStringSync();
  List<String> lines = contents.split('\n');
  List<String> newLines = [];
  
  for (String line in lines) {
    newLines.add(line);
    if (line.contains('- assets/auth/') && line.contains('.jpeg')) {
      newLines.add(line.replaceAll('.jpeg', '.png'));
    }
  }
  
  file.writeAsStringSync(newLines.join('\n'));
}
