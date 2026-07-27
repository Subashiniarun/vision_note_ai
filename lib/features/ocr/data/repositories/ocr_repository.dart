import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/repositories/i_ocr_repository.dart';
import '../datasources/local/ocr_engine.dart';
import '../datasources/remote/cloud_ocr_engine.dart';

@Injectable(as: IOCRRepository)
class OCRRepository implements IOCRRepository {
  final OCREngine _engine;
  final CloudOCREngine _cloudEngine;

  OCRRepository(this._engine, this._cloudEngine);

  @override
  Future<OCRResult> extractText(Uint8List imageBytes, String language, {bool useCloudOCR = false}) async {
    if (useCloudOCR) {
      return await _cloudEngine.transcribe(imageBytes, language);
    }
    return await _engine.recognizeText(imageBytes, language);
  }

  @override
  Future<List<String>> getAvailableLanguages() async {
    return [
      'en', 'es', 'fr', 'de', 'it', 'pt', 'nl', 'ru', 'ja', 'ko', 'zh',
    ];
  }
}
