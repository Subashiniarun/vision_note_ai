import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ImageUtils {
  static Future<Uint8List> resizeImage(
    Uint8List data,
    int maxWidth,
    int maxHeight,
  ) async {
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    final original = frame.image;
    final width = original.width;
    final height = original.height;

    double scale = 1.0;
    if (width > maxWidth) scale = maxWidth / width;
    if (height * scale > maxHeight) {
      scale = maxHeight / height;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width * scale, height * scale);
    final paint = Paint()..filterQuality = FilterQuality.high;

    canvas.drawImageRect(
      original,
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    codec.dispose();

    return byteData!.buffer.asUint8List();
  }

  static Size decodeImageDimensions(Uint8List data) {
    final bytes = ByteData.view(data.buffer);
    int width = 0;
    int height = 0;

    for (int i = 0; i < data.length - 1; i++) {
      if (data[i] == 0xFF && data[i + 1] == 0xD8) {
        int offset = i + 2;
        while (offset < data.length - 1) {
          if (data[offset] == 0xFF && data[offset + 1] == 0xC0 ||
              data[offset] == 0xFF && data[offset + 1] == 0xC2) {
            height = (data[offset + 5] << 8) | data[offset + 6];
            width = (data[offset + 7] << 8) | data[offset + 8];
            break;
          }
          offset++;
        }
        break;
      }
    }
    return Size(width.toDouble(), height.toDouble());
  }
}
