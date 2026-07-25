import 'dart:typed_data';
import '../entities/ocr_result.dart';

abstract class IOCRRepository {
  Future<OCRResult> extractText(Uint8List imageBytes, String language);
  Future<List<String>> getAvailableLanguages();
}
