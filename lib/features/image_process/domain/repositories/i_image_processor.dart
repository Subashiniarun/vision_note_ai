import 'dart:typed_data';
import 'dart:ui';

abstract class IImageProcessor {
  Future<Uint8List> detectEdges(Uint8List image);
  Future<Uint8List> correctPerspective(
      Uint8List image, List<Offset> corners);
  Future<Uint8List> autoEnhance(Uint8List image);
  Future<Uint8List> adjustBrightness(Uint8List image, int value);
  Future<Uint8List> adjustContrast(Uint8List image, double value);
  Future<Uint8List> adjustSaturation(Uint8List image, double value);
  Future<Uint8List> deskew(Uint8List image);
  Future<List<Offset>> detectDocumentCorners(Uint8List image);
  Future<Uint8List> resizeImage(Uint8List image, int maxWidth, int maxHeight);
}
