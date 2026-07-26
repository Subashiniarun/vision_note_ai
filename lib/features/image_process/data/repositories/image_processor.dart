import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:math' as math;
import 'package:injectable/injectable.dart';
import '../../domain/repositories/i_image_processor.dart';
import '../../../../core/utils/logger.dart';
import '../../../../native/ffi/opencv_service.dart';
import '../../../../core/di/injection.dart' as di;

@Injectable(as: IImageProcessor)
class ImageProcessor implements IImageProcessor {
  static final _log = VNALogger.get('ImageProcessor');
  final OpenCVService? _native;

  ImageProcessor() : _native = _tryInitNative();

  static OpenCVService? _tryInitNative() {
    try {
      return di.getIt<OpenCVService>();
    } catch (_) {
      return null;
    }
  }

  Future<_Decoded> _decode(Uint8List data) async {
    final codec = await instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    final img = frame.image;
    final bytes = (await img.toByteData())!.buffer.asUint8List();
    return _Decoded(bytes, img.width, img.height);
  }

  Future<Uint8List> _encode(Uint8List rgba, int w, int h) async {
    final img = decodeImageFromPixelsSync(rgba, w, h, PixelFormat.rgba8888);
    final bytes = await img.toByteData(format: ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  @override
  Future<Uint8List> detectEdges(Uint8List image) async {
    final d = await _decode(image);
    final result = await Isolate.run(() => _edgePipeline(d.data, d.w, d.h));
    return _encode(result, d.w, d.h);
  }

  @override
  Future<Uint8List> correctPerspective(Uint8List image, List<Offset> corners) async {
    if (corners.length < 4) return image;
    _log.info('Correcting perspective');
    if (_native != null) {
      try {
        final d = await _decode(image);
        final result = _native!.correctPerspective(d.data, d.w, d.h, corners);
        if (result != null) return result;
      } catch (e) {
        _log.warning('Native perspective correction failed, falling back', e);
      }
    }
    try {
      final codec = await instantiateImageCodec(image);
      final frame = await codec.getNextFrame();
      final srcImage = frame.image;
      final w = srcImage.width;
      final h = srcImage.height;

      const grid = 32;
      final verts = <Offset>[];
      final uvs = <Offset>[];
      final idxs = <int>[];

      final r = Rect.fromPoints(
        corners.reduce((a, b) => Offset(a.dx < b.dx ? a.dx : b.dx, a.dy < b.dy ? a.dy : b.dy)),
        corners.reduce((a, b) => Offset(a.dx > b.dx ? a.dx : b.dx, a.dy > b.dy ? a.dy : b.dy)),
      );

      for (int gy = 0; gy <= grid; gy++) {
        for (int gx = 0; gx <= grid; gx++) {
          final u = gx / grid;
          final v = gy / grid;
          final topX = _lerp(corners[0].dx, corners[1].dx, u);
          final topY = _lerp(corners[0].dy, corners[1].dy, u);
          final botX = _lerp(corners[3].dx, corners[2].dx, u);
          final botY = _lerp(corners[3].dy, corners[2].dy, u);
          verts.add(Offset(_lerp(topX, botX, v) - r.left, _lerp(topY, botY, v) - r.top));
          uvs.add(Offset(u * w, v * h));
          if (gx < grid && gy < grid) {
            final idx = gy * (grid + 1) + gx;
            idxs.addAll([idx, idx + 1, idx + grid + 1, idx + 1, idx + grid + 2, idx + grid + 1]);
          }
        }
      }

      final m = Float64List(16)
        ..[0] = 1..[5] = 1..[10] = 1..[15] = 1;

      final rec = PictureRecorder();
      final c = Canvas(rec, Rect.fromLTWH(0, 0, r.width, r.height));
      c.drawVertices(
        Vertices(VertexMode.triangles, verts, textureCoordinates: uvs, indices: idxs),
        BlendMode.srcOver,
        Paint()..shader = ImageShader(srcImage, TileMode.clamp, TileMode.clamp, m),
      );
      final img = await rec.endRecording().toImage(r.width.toInt(), r.height.toInt());
      final bytes = await img.toByteData(format: ImageByteFormat.png);
      return bytes!.buffer.asUint8List();
    } catch (e) {
      _log.severe('Perspective correction failed', e);
      return image;
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Future<Uint8List> autoEnhance(Uint8List image) async {
    _log.info('Running auto enhance');
    if (_native != null) {
      try {
        final d = await _decode(image);
        final result = _native!.autoEnhance(d.data, d.w, d.h);
        if (result != null) return result;
      } catch (e) {
        _log.warning('Native auto enhance failed, falling back', e);
      }
    }
    try {
      final d = await _decode(image);
      final result = await Isolate.run(() => _enhancePipeline(d.data, d.w, d.h));
      return _encode(result, d.w, d.h);
    } catch (e) {
      _log.severe('Auto enhance failed', e);
      return image;
    }
  }

  @override
  Future<Uint8List> adjustBrightness(Uint8List image, int value) async {
    if (value == 0) return image;
    try {
      final d = await _decode(image);
      final result = await Isolate.run(() => _brightnessPixels(d.data, value));
      return _encode(result, d.w, d.h);
    } catch (_) { return image; }
  }

  @override
  Future<Uint8List> adjustContrast(Uint8List image, double value) async {
    if (value == 1.0) return image;
    try {
      final d = await _decode(image);
      final result = await Isolate.run(() => _contrastPixels(d.data, value));
      return _encode(result, d.w, d.h);
    } catch (_) { return image; }
  }

  @override
  Future<Uint8List> adjustSaturation(Uint8List image, double value) async {
    if (value == 1.0) return image;
    try {
      final d = await _decode(image);
      final result = await Isolate.run(() => _saturationPixels(d.data, value));
      return _encode(result, d.w, d.h);
    } catch (_) { return image; }
  }

  @override
  Future<Uint8List> deskew(Uint8List image) async {
    _log.info('Deskewing');
    try {
      final codec = await instantiateImageCodec(image);
      final frame = await codec.getNextFrame();
      final img = frame.image;
      final w = img.width;
      final h = img.height;
      final bytes = (await img.toByteData())!.buffer.asUint8List();

      final angle = await Isolate.run(() => _detectSkewAngle(bytes, w, h));
      if (angle.abs() < 0.5) return image;

      final rad = angle * math.pi / 180;
      final cos = math.cos(rad).abs();
      final sin = math.sin(rad).abs();
      final newW = (w * cos + h * sin).toInt();
      final newH = (w * sin + h * cos).toInt();

      final rec = PictureRecorder();
      final c = Canvas(rec, Rect.fromLTWH(0, 0, newW.toDouble(), newH.toDouble()));
      c.translate(newW / 2, newH / 2);
      c.rotate(rad);
      c.drawImage(img, Offset(-w / 2, -h / 2), Paint()..filterQuality = FilterQuality.high);

      final out = await rec.endRecording().toImage(newW, newH);
      final bytesOut = await out.toByteData(format: ImageByteFormat.png);
      return bytesOut!.buffer.asUint8List();
    } catch (e) {
      _log.severe('Deskew failed', e);
      return image;
    }
  }

  @override
  Future<List<Offset>> detectDocumentCorners(Uint8List image) async {
    _log.info('Detecting document corners');
    try {
      final d = await _decode(image);
      if (_native != null) {
        _log.info('Using native OpenCV corner detection');
        final corners = _native!.detectDocumentCorners(d.data, d.w, d.h);
        if (corners != null && corners.length == 4) return corners;
        _log.info('Native corner detection failed, falling back to Dart');
      }
      return await Isolate.run(() => _findCorners(d.data, d.w, d.h));
    } catch (e) {
      _log.severe('Corner detection failed', e);
      return [];
    }
  }

  @override
  Future<Uint8List> resizeImage(Uint8List image, int maxWidth, int maxHeight) async {
    if (image.isEmpty) return image;
    try {
      final codec = await instantiateImageCodec(image);
      final frame = await codec.getNextFrame();
      final original = frame.image;
      final w = original.width;
      final h = original.height;
      if (w <= maxWidth && h <= maxHeight) return image;

      final s = math.min(maxWidth / w, maxHeight / h);
      final nw = (w * s).toInt();
      final nh = (h * s).toInt();

      final rec = PictureRecorder();
      final c = Canvas(rec);
      c.drawImageRect(original, Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
          Rect.fromLTWH(0, 0, nw.toDouble(), nh.toDouble()), Paint()..filterQuality = FilterQuality.high);
      final img = await rec.endRecording().toImage(nw, nh);
      final bytes = await img.toByteData(format: ImageByteFormat.png);
      return bytes!.buffer.asUint8List();
    } catch (_) { return image; }
  }

  // ---- Isolate pipelines (pure byte operations, no dart:ui) ----

  static Uint8List _edgePipeline(Uint8List rgba, int w, int h) {
    var gray = _rgbaToGray(rgba, w, h);
    gray = _gaussianBlur(gray, w, h, 1.0);
    gray = _sobelEdges(gray, w, h);
    gray = _nonMaxSuppression(gray, w, h);
    gray = _doubleThreshold(gray, w, h, 40, 100);
    gray = _edgeTrack(gray, w, h);

    final out = Uint8List(w * h * 4);
    for (int i = 0; i < w * h; i++) {
      final v = gray[i];
      out[i * 4] = v;
      out[i * 4 + 1] = v;
      out[i * 4 + 2] = v;
      out[i * 4 + 3] = 255;
    }
    return out;
  }

  static Uint8List _enhancePipeline(Uint8List rgba, int w, int h) {
    var gray = _rgbaToGray(rgba, w, h);
    gray = _clahe(gray, w, h, 8, 256);
    gray = _medianFilter(gray, w, h, 3);
    gray = _unsharpMask(gray, w, h, 1.5);

    final out = Uint8List(w * h * 4);
    for (int i = 0; i < w * h; i++) {
      final v = gray[i];
      out[i * 4] = v;
      out[i * 4 + 1] = v;
      out[i * 4 + 2] = v;
      out[i * 4 + 3] = 255;
    }
    return out;
  }

  static Uint8List _brightnessPixels(Uint8List rgba, int delta) {
    final out = Uint8List.fromList(rgba);
    for (int i = 0; i < out.length; i += 4) {
      out[i] = (out[i] + delta).clamp(0, 255);
      out[i + 1] = (out[i + 1] + delta).clamp(0, 255);
      out[i + 2] = (out[i + 2] + delta).clamp(0, 255);
    }
    return out;
  }

  static Uint8List _contrastPixels(Uint8List rgba, double factor) {
    final out = Uint8List.fromList(rgba);
    for (int i = 0; i < out.length; i += 4) {
      out[i] = ((out[i] - 128) * factor + 128).round().clamp(0, 255);
      out[i + 1] = ((out[i + 1] - 128) * factor + 128).round().clamp(0, 255);
      out[i + 2] = ((out[i + 2] - 128) * factor + 128).round().clamp(0, 255);
    }
    return out;
  }

  static Uint8List _saturationPixels(Uint8List rgba, double factor) {
    final out = Uint8List.fromList(rgba);
    for (int i = 0; i < out.length; i += 4) {
      final r = out[i];
      final g = out[i + 1];
      final b = out[i + 2];
      final gray = (0.299 * r + 0.587 * g + 0.114 * b).round();
      out[i] = (gray + ((r - gray) * factor)).round().clamp(0, 255);
      out[i + 1] = (gray + ((g - gray) * factor)).round().clamp(0, 255);
      out[i + 2] = (gray + ((b - gray) * factor)).round().clamp(0, 255);
    }
    return out;
  }

  static List<Offset> _findCorners(Uint8List rgba, int w, int h) {
    var gray = _rgbaToGray(rgba, w, h);
    gray = _gaussianBlur(gray, w, h, 0.5);
    gray = _medianFilter(gray, w, h, 3);

    final threshold = _otsuThreshold(gray, w, h);
    final binary = Uint8List(w * h);
    for (int i = 0; i < w * h; i++) {
      binary[i] = gray[i] < threshold ? 0 : 255;
    }

    const step = 4;
    final pad = 16.0;

    double? top, bottom, left, right;

    for (int y = 0; y < h; y += step) {
      int darkCount = 0;
      for (int x = 0; x < w; x += step) {
        if (binary[y * w + x] == 0) darkCount++;
      }
      if (darkCount > w ~/ step ~/ 4) { top = y.toDouble(); break; }
    }

    for (int y = h - 1; y >= 0; y -= step) {
      int darkCount = 0;
      for (int x = 0; x < w; x += step) {
        if (binary[y * w + x] == 0) darkCount++;
      }
      if (darkCount > w ~/ step ~/ 4) { bottom = y.toDouble(); break; }
    }

    for (int x = 0; x < w; x += step) {
      int darkCount = 0;
      for (int y = 0; y < h; y += step) {
        if (binary[y * w + x] == 0) darkCount++;
      }
      if (darkCount > h ~/ step ~/ 4) { left = x.toDouble(); break; }
    }

    for (int x = w - 1; x >= 0; x -= step) {
      int darkCount = 0;
      for (int y = 0; y < h; y += step) {
        if (binary[y * w + x] == 0) darkCount++;
      }
      if (darkCount > h ~/ step ~/ 4) { right = x.toDouble(); break; }
    }

    if (top == null || bottom == null || left == null || right == null) return [];

    return [
      Offset(math.max(0, left - pad), math.max(0, top - pad)),
      Offset(math.min(w.toDouble(), right + pad), math.max(0, top - pad)),
      Offset(math.min(w.toDouble(), right + pad), math.min(h.toDouble(), bottom + pad)),
      Offset(math.max(0, left - pad), math.min(h.toDouble(), bottom + pad)),
    ];
  }

  static double _detectSkewAngle(Uint8List rgba, int w, int h) {
    final gray = _rgbaToGray(rgba, w, h);
    double bestAngle = 0;
    int bestScore = 0;
    const step = 4;

    for (double angle = -15; angle <= 15; angle += 0.5) {
      final rad = angle * math.pi / 180;
      final cosA = math.cos(rad);
      final sinA = math.sin(rad);
      int score = 0;

      for (int y = 0; y < h; y += step) {
        for (int x = 0; x < w; x += step) {
          final rx = x * cosA - y * sinA + w / 2;
          final ry = x * sinA + y * cosA + h / 2;

          if (rx >= 0 && rx < w - 1 && ry >= 0 && ry < h - 1) {
            final idx = ry.toInt() * w + rx.toInt();
            final next = ry.toInt() * w + (rx.toInt() + 1);
            if (idx < gray.length && next < gray.length && (gray[idx] - gray[next]).abs() > 30) score++;
          }
        }
      }

      if (score > bestScore) { bestScore = score; bestAngle = angle; }
    }
    return bestAngle;
  }

  // ---- Pixel utilities ----

  static Uint8List _rgbaToGray(Uint8List rgba, int w, int h) {
    final gray = Uint8List(w * h);
    for (int i = 0; i < w * h; i++) {
      gray[i] = (rgba[i * 4] * 0.299 + rgba[i * 4 + 1] * 0.587 + rgba[i * 4 + 2] * 0.114).round().clamp(0, 255);
    }
    return gray;
  }

  static int _otsuThreshold(Uint8List src, int w, int h) {
    final hist = List.filled(256, 0);
    final total = w * h;
    for (int i = 0; i < total; i++) hist[src[i]]++;

    double sum = 0;
    for (int i = 0; i < 256; i++) sum += i * hist[i];

    double sumB = 0;
    int wB = 0, wF = 0;
    double maxVariance = 0;
    int threshold = 0;

    for (int i = 0; i < 256; i++) {
      wB += hist[i];
      if (wB == 0) continue;
      wF = total - wB;
      if (wF == 0) break;

      sumB += i * hist[i];
      final mB = sumB / wB;
      final mF = (sum - sumB) / wF;
      final variance = wB * wF * (mB - mF) * (mB - mF);

      if (variance > maxVariance) { maxVariance = variance; threshold = i; }
    }
    return threshold;
  }

  static Uint8List _gaussianBlur(Uint8List src, int w, int h, double sigma) {
    final radius = (sigma * 3).ceil();
    final size = radius * 2 + 1;
    final kernel = List.filled(size, 0.0);
    double sum = 0;
    for (int i = 0; i < size; i++) {
      kernel[i] = math.exp(-((i - radius) * (i - radius)) / (2 * sigma * sigma));
      sum += kernel[i];
    }
    for (int i = 0; i < size; i++) kernel[i] /= sum;

    final tmp = Uint8List(w * h);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        double v = 0;
        for (int k = 0; k < size; k++) v += src[y * w + (x + k - radius).clamp(0, w - 1)] * kernel[k];
        tmp[y * w + x] = v.round().clamp(0, 255);
      }
    }

    final dst = Uint8List(w * h);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        double v = 0;
        for (int k = 0; k < size; k++) v += tmp[((y + k - radius).clamp(0, h - 1)) * w + x] * kernel[k];
        dst[y * w + x] = v.round().clamp(0, 255);
      }
    }
    return dst;
  }

  static Uint8List _sobelEdges(Uint8List src, int w, int h) {
    final dst = Uint8List(w * h);
    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        final gx = -src[(y-1)*w+(x-1)] + src[(y-1)*w+(x+1)] -2*src[y*w+(x-1)] + 2*src[y*w+(x+1)] -src[(y+1)*w+(x-1)] + src[(y+1)*w+(x+1)];
        final gy = -src[(y-1)*w+(x-1)] -2*src[(y-1)*w+x] -src[(y-1)*w+(x+1)] + src[(y+1)*w+(x-1)] +2*src[(y+1)*w+x] + src[(y+1)*w+(x+1)];
        dst[y * w + x] = math.sqrt(gx * gx + gy * gy).round().clamp(0, 255);
      }
    }
    return dst;
  }

  static Uint8List _nonMaxSuppression(Uint8List mag, int w, int h) {
    final dst = Uint8List(w * h);
    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        final v = mag[y * w + x];
        if (v == 0) continue;
        bool isMax = true;
        for (int dy = -1; dy <= 1 && isMax; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            if ((dy != 0 || dx != 0) && mag[(y + dy) * w + (x + dx)] > v) { isMax = false; break; }
          }
        }
        if (isMax) dst[y * w + x] = v;
      }
    }
    return dst;
  }

  static Uint8List _doubleThreshold(Uint8List src, int w, int h, int low, int high) {
    final dst = Uint8List(w * h);
    for (int i = 0; i < w * h; i++) dst[i] = src[i] >= high ? 255 : (src[i] >= low ? 128 : 0);
    return dst;
  }

  static Uint8List _edgeTrack(Uint8List src, int w, int h) {
    final dst = Uint8List.fromList(src);
    bool changed = true;
    while (changed) {
      changed = false;
      for (int y = 1; y < h - 1; y++) {
        for (int x = 1; x < w - 1; x++) {
          if (dst[y * w + x] != 128) continue;
          for (int dy = -1; dy <= 1 && !changed; dy++) {
            for (int dx = -1; dx <= 1; dx++) {
              if (dst[(y + dy) * w + (x + dx)] == 255) { dst[y * w + x] = 255; changed = true; break; }
            }
          }
        }
      }
    }
    for (int i = 0; i < w * h; i++) if (dst[i] != 255) dst[i] = 0;
    return dst;
  }

  static Uint8List _clahe(Uint8List src, int w, int h, int gridSize, int clipLimit) {
    final tilesX = (w + gridSize - 1) ~/ gridSize;
    final tilesY = (h + gridSize - 1) ~/ gridSize;
    final cdfs = List.generate(tilesY, (_) => List.generate(tilesX, (_) => List.filled(256, 0.0)));

    for (int ty = 0; ty < tilesY; ty++) {
      for (int tx = 0; tx < tilesX; tx++) {
        final hist = List.filled(256, 0);
        final x0 = tx * gridSize, y0 = ty * gridSize;
        final x1 = math.min(x0 + gridSize, w), y1 = math.min(y0 + gridSize, h);
        for (int y = y0; y < y1; y++) for (int x = x0; x < x1; x++) hist[src[y * w + x]]++;

        int clipped = 0;
        final limit = (gridSize * gridSize) ~/ clipLimit;
        for (int i = 0; i < 256; i++) { if (hist[i] > limit) { clipped += hist[i] - limit; hist[i] = limit; } }
        for (int i = 0; i < 256; i++) hist[i] += clipped ~/ 256;

        int sum = 0;
        for (int i = 0; i < 256; i++) { sum += hist[i]; cdfs[ty][tx][i] = sum / (gridSize * gridSize); }
      }
    }

    final dst = Uint8List(w * h);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final v = src[y * w + x];
        final tx = (x * tilesX ~/ w).clamp(0, tilesX - 1);
        final ty = (y * tilesY ~/ h).clamp(0, tilesY - 1);
        final tx0 = math.max(0, tx - 1), tx1 = math.min(tilesX - 1, tx + 1);
        final ty0 = math.max(0, ty - 1), ty1 = math.min(tilesY - 1, ty + 1);

        double result = 0;
        int count = 0;
        for (int ny = ty0; ny <= ty1; ny++) for (int nx = tx0; nx <= tx1; nx++) { result += cdfs[ny][nx][v] * 255; count++; }
        dst[y * w + x] = (result / count).round().clamp(0, 255);
      }
    }
    return dst;
  }

  static Uint8List _medianFilter(Uint8List src, int w, int h, int ksize) {
    final dst = Uint8List(w * h);
    final radius = ksize ~/ 2;
    final neighbors = List.filled(ksize * ksize, 0);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        int idx = 0;
        for (int dy = -radius; dy <= radius; dy++) for (int dx = -radius; dx <= radius; dx++) {
          neighbors[idx++] = src[((y + dy).clamp(0, h - 1)) * w + (x + dx).clamp(0, w - 1)];
        }
        neighbors.sort();
        dst[y * w + x] = neighbors[neighbors.length ~/ 2];
      }
    }
    return dst;
  }

  static Uint8List _unsharpMask(Uint8List src, int w, int h, double amount) {
    final blurred = _gaussianBlur(src, w, h, 1.0);
    final dst = Uint8List(w * h);
    for (int i = 0; i < w * h; i++) dst[i] = (src[i] + amount * (src[i] - blurred[i])).round().clamp(0, 255);
    return dst;
  }
}

class _Decoded {
  final Uint8List data;
  final int w;
  final int h;
  _Decoded(this.data, this.w, this.h);
}
