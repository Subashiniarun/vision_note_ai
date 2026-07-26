import 'dart:typed_data';
import 'dart:ui' show Size;

class ImageUtils {
  static Size decodeImageDimensions(Uint8List data) {
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
