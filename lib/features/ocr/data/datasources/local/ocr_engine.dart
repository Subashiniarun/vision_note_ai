import 'dart:typed_data';
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
    hide TextBlock, TextLine, TextWord;
import '../../../domain/entities/ocr_result.dart';

class OCREngine {
  Future<OCRResult> recognizeText(Uint8List imageBytes, String language) async {
    final navigator = InputImage.fromBytes(
      bytes: imageBytes,
      metadata: InputImageMetadata(
        size: Size.zero,
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.yuv_420_888,
        bytesPerRow: 0,
      ),
    );

    final extractor = TextRecognizer(
      script: _mapLanguage(language),
    );

    try {
      final result = await extractor.processImage(navigator);
      final text = result.text;
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

      final avgConfidence = blocks.isEmpty
          ? 0.0
          : blocks
                  .expand((b) => b.lines)
                  .expand((l) => l.words)
                  .fold<double>(0.0, (sum, w) => sum + w.confidence) /
              (blocks.expand((b) => b.lines).expand((l) => l.words).length)
                  .toDouble();

      return OCRResult(
        text: text,
        blocks: blocks,
        language: language,
        confidence: avgConfidence,
      );
    } finally {
      extractor.close();
    }
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
