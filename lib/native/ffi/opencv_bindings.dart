import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ffi/ffi.dart';

typedef DetectEdgesNative = Pointer<Utf8> Function(
  Pointer<Uint8> imageData,
  Int32 width,
  Int32 height,
  Int32 channels,
);

typedef DetectEdgesDart = Pointer<Utf8> Function(
  Pointer<Uint8> imageData,
  int width,
  int height,
  int channels,
);

typedef CorrectPerspectiveNative = Pointer<Utf8> Function(
  Pointer<Uint8> imageData,
  Int32 width,
  Int32 height,
  Int32 channels,
  Float x1, Float y1,
  Float x2, Float y2,
  Float x3, Float y3,
  Float x4, Float y4,
);

typedef CorrectPerspectiveDart = Pointer<Utf8> Function(
  Pointer<Uint8> imageData,
  int width, int height, int channels,
  double x1, double y1,
  double x2, double y2,
  double x3, double y3,
  double x4, double y4,
);

typedef AutoEnhanceNative = Pointer<Utf8> Function(
  Pointer<Uint8> imageData,
  Int32 width,
  Int32 height,
  Int32 channels,
);

typedef AutoEnhanceDart = Pointer<Utf8> Function(
  Pointer<Uint8> imageData,
  int width,
  int height,
  int channels,
);

typedef HandwritingProcNative = Pointer<Utf8> Function(
  Pointer<Uint8> imageData,
  Int32 width,
  Int32 height,
  Int32 channels,
);

typedef HandwritingProcDart = Pointer<Utf8> Function(
  Pointer<Uint8> imageData,
  int width,
  int height,
  int channels,
);

class OpenCVBindings {
  DynamicLibrary? _lib;

  DynamicLibrary get _library {
    if (_lib != null) return _lib!;
    if (Platform.isAndroid) {
      _lib = DynamicLibrary.open('libopencv_processor.so');
    } else if (Platform.isIOS) {
      _lib = DynamicLibrary.process();
    } else {
      throw UnsupportedError('OpenCV FFI is only supported on Android/iOS');
    }
    return _lib!;
  }

  DetectEdgesDart get detectEdges {
    return _library
        .lookupFunction<DetectEdgesNative, DetectEdgesDart>('detect_document_edges');
  }

  CorrectPerspectiveDart get correctPerspective {
    return _library
        .lookupFunction<CorrectPerspectiveNative, CorrectPerspectiveDart>(
            'correct_perspective');
  }

  AutoEnhanceDart get autoEnhance {
    return _library
        .lookupFunction<AutoEnhanceNative, AutoEnhanceDart>('auto_enhance');
  }

  HandwritingProcDart get preprocessForHandwriting {
    return _library
        .lookupFunction<HandwritingProcNative, HandwritingProcDart>(
            'preprocess_for_handwriting');
  }
}
