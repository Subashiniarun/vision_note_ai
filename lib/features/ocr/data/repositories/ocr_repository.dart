import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/repositories/i_ocr_repository.dart';
import '../datasources/local/ocr_engine.dart';

@Injectable(as: IOCRRepository)
class OCRRepository implements IOCRRepository {
  final OCREngine _engine;

  OCRRepository(this._engine);

  @override
  Future<OCRResult> extractText(Uint8List imageBytes, String language) async {
    return await _engine.recognizeText(imageBytes, language);
  }

  @override
  Future<List<String>> getAvailableLanguages() async {
    return [
      'en', 'es', 'fr', 'de', 'it', 'pt', 'nl', 'ru', 'ja', 'ko', 'zh',
    ];
  }
}
