import 'dart:io';
import 'dart:typed_data';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
    hide TextBlock, TextLine;
import 'package:path_provider/path_provider.dart';
import '../../../domain/entities/ocr_result.dart';

class OCREngine {
  TextRecognizer? _recognizer;
  String _currentScript = '';

  TextRecognizer _getRecognizer(String language) {
    final script = _mapLanguage(language);
    if (_recognizer != null && _currentScript == script.name) {
      return _recognizer!;
    }
    _recognizer?.close();
    _recognizer = TextRecognizer(script: script);
    _currentScript = script.name;
    return _recognizer!;
  }

  Future<OCRResult> recognizeText(Uint8List imageBytes, String language) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(path);
    await file.writeAsBytes(imageBytes);
    final navigator = InputImage.fromFile(file);

    final extractor = _getRecognizer(language);

    try {
      final result = await extractor.processImage(navigator);
      final blocks = result.blocks.map((b) => TextBlock(
            text: b.text,
            boundingBox: b.boundingBox,
            lines: b.lines.map((l) => TextLine(
                  text: l.text,
                  boundingBox: l.boundingBox,
                  words: l.elements.map((e) => TextWord(
                        text: e.text,
                        boundingBox: e.boundingBox,
                        confidence: e.confidence ?? 0.0,
                      )).toList(),
                )).toList(),
          )).toList();

      final allWords = blocks
          .expand((b) => b.lines)
          .expand((l) => l.words)
          .toList();

      final avgConfidence = allWords.isEmpty
          ? 0.0
          : allWords.fold<double>(0.0, (sum, w) => sum + w.confidence) /
              allWords.length;

      return OCRResult(
        text: result.text,
        blocks: blocks,
        language: language,
        confidence: avgConfidence,
      );
    } finally {
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  void dispose() {
    _recognizer?.close();
    _recognizer = null;
  }

  TextRecognitionScript _mapLanguage(String language) {
    switch (language) {
      case 'ja':
        return TextRecognitionScript.japanese;
      case 'ko':
        return TextRecognitionScript.korean;
      case 'zh':
        return TextRecognitionScript.chinese;
      default:
        return TextRecognitionScript.latin;
    }
  }
}
