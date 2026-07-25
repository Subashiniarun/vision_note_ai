import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  Future<Directory> get _appDir => getApplicationDocumentsDirectory();

  Future<String> saveOriginalImage(Uint8List bytes, String scanId) async {
    final dir = Directory('${(await _appDir).path}/scans/$scanId/original');
    await dir.create(recursive: true);
    final file = File('${dir.path}/original.jpg');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<String> saveEnhancedImage(Uint8List bytes, String scanId) async {
    final dir = Directory('${(await _appDir).path}/scans/$scanId/enhanced');
    await dir.create(recursive: true);
    final file = File('${dir.path}/enhanced.jpg');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> deleteScanFiles(String scanId) async {
    final dir = Directory('${(await _appDir).path}/scans/$scanId');
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<String> exportToFile(String content, String fileName) async {
    final dir = Directory('${(await _appDir).path}/exports');
    await dir.create(recursive: true);
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }

  Future<String> exportBytesToFile(
    Uint8List bytes,
    String fileName,
  ) async {
    final dir = Directory('${(await _appDir).path}/exports');
    await dir.create(recursive: true);
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
