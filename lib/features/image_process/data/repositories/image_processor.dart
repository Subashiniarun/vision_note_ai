import 'dart:typed_data';
import 'dart:ui';
import 'dart:math' as math;
import 'package:injectable/injectable.dart';
import '../../domain/repositories/i_image_processor.dart';

@Injectable(as: IImageProcessor)
class ImageProcessor implements IImageProcessor {
  @override
  Future<Uint8List> detectEdges(Uint8List image) async {
    return image;
  }

  @override
  Future<Uint8List> correctPerspective(Uint8List image, List<Offset> corners) async {
    if (corners.length < 4) return image;
    try {
      final codec = await instantiateImageCodec(image);
      final frame = await codec.getNextFrame();
      final srcImage = frame.image;
      final w = srcImage.width.toDouble();
      final h = srcImage.height.toDouble();

      final vertices = Vertices(
        VertexMode.triangles,
        [
          Offset(0, 0), Offset(w, 0), Offset(w, h),
          Offset(0, 0), Offset(w, h), Offset(0, h),
        ],
        textureCoordinates: [
          corners[0], corners[1], corners[2],
          corners[0], corners[2], corners[3],
        ],
      );

      final dstRect = Rect.fromLTWH(0, 0, w, h);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder, dstRect);

      final identity = Float64List(16)
        ..[0] = 1
        ..[5] = 1
        ..[10] = 1
        ..[15] = 1;
      final shader = ImageShader(
        srcImage,
        TileMode.clamp,
        TileMode.clamp,
        identity,
      );
      canvas.drawVertices(vertices, BlendMode.srcOver, Paint()..shader = shader);

      final picture = recorder.endRecording();
      final dstImage = await picture.toImage(srcImage.width, srcImage.height);
      final byteData = await dstImage.toByteData(format: ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (_) {
      return image;
    }
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
    try {
      final codec = await instantiateImageCodec(image);
      final frame = await codec.getNextFrame();
      final img = frame.image;
      final w = img.width;
      final h = img.height;

      final byteData = await img.toByteData();
      if (byteData == null) return [];

      final pixels = byteData.buffer.asUint8List();
      const step = 6;
      const threshold = 180;

      double? top, bottom, left, right;

      for (int y = 0; y < h; y += step) {
        bool hasContent = false;
        for (int x = 0; x < w; x += step) {
          final idx = (y * w + x) * 4;
          if (idx + 2 < pixels.length) {
            final r = pixels[idx];
            final g = pixels[idx + 1];
            final b = pixels[idx + 2];
            if ((r + g + b) / 3 < threshold) {
              hasContent = true;
              break;
            }
          }
        }
        if (hasContent) {
          top = y.toDouble();
          break;
        }
      }

      for (int y = h - 1; y >= 0; y -= step) {
        bool hasContent = false;
        for (int x = 0; x < w; x += step) {
          final idx = (y * w + x) * 4;
          if (idx + 2 < pixels.length) {
            final r = pixels[idx];
            final g = pixels[idx + 1];
            final b = pixels[idx + 2];
            if ((r + g + b) / 3 < threshold) {
              hasContent = true;
              break;
            }
          }
        }
        if (hasContent) {
          bottom = y.toDouble();
          break;
        }
      }

      for (int x = 0; x < w; x += step) {
        bool hasContent = false;
        for (int y = 0; y < h; y += step) {
          final idx = (y * w + x) * 4;
          if (idx + 2 < pixels.length) {
            final r = pixels[idx];
            final g = pixels[idx + 1];
            final b = pixels[idx + 2];
            if ((r + g + b) / 3 < threshold) {
              hasContent = true;
              break;
            }
          }
        }
        if (hasContent) {
          left = x.toDouble();
          break;
        }
      }

      for (int x = w - 1; x >= 0; x -= step) {
        bool hasContent = false;
        for (int y = 0; y < h; y += step) {
          final idx = (y * w + x) * 4;
          if (idx + 2 < pixels.length) {
            final r = pixels[idx];
            final g = pixels[idx + 1];
            final b = pixels[idx + 2];
            if ((r + g + b) / 3 < threshold) {
              hasContent = true;
              break;
            }
          }
        }
        if (hasContent) {
          right = x.toDouble();
          break;
        }
      }

      if (top == null || bottom == null || left == null || right == null) return [];

      const pad = 12.0;
      return [
        Offset(math.max(0, left - pad), math.max(0, top - pad)),
        Offset(math.min(w.toDouble(), right + pad), math.max(0, top - pad)),
        Offset(math.min(w.toDouble(), right + pad), math.min(h.toDouble(), bottom + pad)),
        Offset(math.max(0, left - pad), math.min(h.toDouble(), bottom + pad)),
      ];
    } catch (_) {
      return [];
    }
  }
}
