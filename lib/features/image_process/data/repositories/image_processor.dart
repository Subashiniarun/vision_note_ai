import 'dart:typed_data';
import 'dart:ui';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/i_image_processor.dart';

@Injectable(as: IImageProcessor)
class ImageProcessor implements IImageProcessor {
  @override
  Future<Uint8List> detectEdges(Uint8List image) async {
    return image;
  }

  @override
  Future<Uint8List> correctPerspective(
      Uint8List image, List<Offset> corners) async {
    return image;
  }

  @override
  Future<Uint8List> autoEnhance(Uint8List image) async {
    return image;
  }

  @override
  Future<Uint8List> adjustBrightness(Uint8List image, int value) async {
    return image;
  }

  @override
  Future<Uint8List> adjustContrast(Uint8List image, double value) async {
    return image;
  }

  @override
  Future<Uint8List> adjustSaturation(Uint8List image, double value) async {
    return image;
  }

  @override
  Future<Uint8List> deskew(Uint8List image) async {
    return image;
  }

  @override
  Future<List<Offset>> detectDocumentCorners(Uint8List image) async {
    return [];
  }
}
