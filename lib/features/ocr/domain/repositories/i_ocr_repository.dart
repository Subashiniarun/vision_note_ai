import 'dart:typed_data';
import '../entities/ocr_result.dart';

abstract class IOCRRepository {
  Future<OCRResult> extractText(Uint8List imageBytes, String language, {bool useCloudOCR = false});
  Future<List<String>> getAvailableLanguages();
}
