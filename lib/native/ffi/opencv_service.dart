import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ffi/ffi.dart';
import 'opencv_bindings.dart';

class OpenCVService {
  final OpenCVBindings _bindings;

  OpenCVService(this._bindings);

  ui.Offset? _parseOffset(Map<String, dynamic> json) {
    return ui.Offset(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
    );
  }

  List<ui.Offset>? detectDocumentCorners(
    Uint8List imageData,
    int width,
    int height,
  ) {
    final ptr = _allocatePointer(imageData);
    final resultPtr = _bindings.detectEdges(ptr, width, height, 4);
    final jsonStr = resultPtr.toDartString();
    _freePtr(ptr);
    _freeStr(resultPtr);

    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    if (data.containsKey('error')) return null;

    final corners = data['corners'] as List;
    if (corners.isEmpty) return null;

    return corners
        .map((c) => _parseOffset(c as Map<String, dynamic>)!)
        .toList();
  }

  Uint8List? correctPerspective(
    Uint8List imageData,
    int width,
    int height,
    List<ui.Offset> corners,
  ) {
    final ptr = _allocatePointer(imageData);
    final resultPtr = _bindings.correctPerspective(
      ptr, width, height, 4,
      corners[0].dx, corners[0].dy,
      corners[1].dx, corners[1].dy,
      corners[2].dx, corners[2].dy,
      corners[3].dx, corners[3].dy,
    );
    final base64 = resultPtr.toDartString();
    _freePtr(ptr);
    _freeStr(resultPtr);

    try {
      return base64Decode(base64);
    } catch (_) {
      return null;
    }
  }

  Uint8List? preprocessForHandwriting(Uint8List imageData, int width, int height) {
    final ptr = _allocatePointer(imageData);
    try {
      final resultPtr = _bindings.preprocessForHandwriting(ptr, width, height, 4);
      final base64 = resultPtr.toDartString();
      _freePtr(ptr);
      _freeStr(resultPtr);
      return base64Decode(base64);
    } catch (_) {
      _freePtr(ptr);
      return null;
    }
  }

  Uint8List? autoEnhance(Uint8List imageData, int width, int height) {
    final ptr = _allocatePointer(imageData);
    final resultPtr = _bindings.autoEnhance(ptr, width, height, 4);
    final base64 = resultPtr.toDartString();
    _freePtr(ptr);
    _freeStr(resultPtr);

    try {
      return base64Decode(base64);
    } catch (_) {
      return null;
    }
  }

  Pointer<Uint8> _allocatePointer(Uint8List data) {
    final ptr = malloc.allocate<Uint8>(data.length);
    ptr.asTypedList(data.length).setAll(0, data);
    return ptr;
  }

  void _freePtr(Pointer ptr) => malloc.free(ptr);
  void _freeStr(Pointer<Utf8> ptr) => malloc.free(ptr);
}
