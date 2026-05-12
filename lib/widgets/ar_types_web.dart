import 'dart:ui';

class FaceMesh {
  final List<FaceMeshPoint> points = [];
  final Rect boundingBox = Rect.zero;
}

class FaceMeshPoint {
  final double x = 0, y = 0, z = 0;
}

class Hand {
  final List<HandLandmark> landmarks = [];
}

class HandLandmark {
  final double x = 0, y = 0, z = 0;
}
