import 'dart:convert';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/connectivity_service.dart';
import '../../../../ai/data/datasources/remote/gemini_client.dart';
import '../../../../ai/data/datasources/remote/openai_client.dart';
import '../../../../settings/domain/repositories/i_settings_repository.dart';
import '../../../domain/entities/ocr_result.dart';

@injectable
class CloudOCREngine {
  final GeminiClient _geminiClient;
  final OpenAIClient _openAIClient;
  final ISettingsRepository _settingsRepository;
  final ConnectivityService _connectivity;

  CloudOCREngine(
    this._geminiClient,
    this._openAIClient,
    this._settingsRepository,
    this._connectivity,
  );

  Future<OCRResult> transcribe(Uint8List imageBytes, String language) async {
    if (!_connectivity.currentStatus) {
      throw AIOfflineException();
    }

    final settings = await _settingsRepository.load();
    const mimeType = 'image/jpeg';
    final prompt = _buildStructuredPrompt(language);

    String rawResponse;
    if (settings.aiProvider == 'openai') {
      rawResponse = await _openAIClient.transcribeImage(
        systemPrompt: prompt,
        imageBytes: imageBytes,
        mimeType: mimeType,
        model: settings.aiModel.isNotEmpty ? settings.aiModel : null,
        temperature: 0.05,
      );
    } else {
      rawResponse = await _geminiClient.transcribeImage(
        prompt: prompt,
        imageBytes: imageBytes,
        mimeType: mimeType,
        model: settings.aiModel.isNotEmpty ? settings.aiModel : null,
        temperature: 0.05,
      );
    }

    return _parseStructuredResponse(rawResponse, language);
  }

  /// Builds a prompt that instructs the LLM to return structured JSON
  /// with per-line confidence scores, enabling real accuracy computation.
  String _buildStructuredPrompt(String language) {
    final lang = language == 'en' ? 'English' : language;
    return '''You are a precision handwriting recognition engine. 
Carefully analyze the handwritten text in this image and transcribe it.

CRITICAL RULES:
1. For each line of text, provide a confidence score from 0.0 to 1.0 based on how clearly you can read it.
2. If a word is completely illegible, write [unclear] in its place.
3. DO NOT guess unclear words — use [unclear] instead.
4. Return ONLY valid JSON. No explanations, no markdown fences.

Language to transcribe: $lang

Return this exact JSON format:
{
  "lines": [
    { "text": "line of transcribed text here", "confidence": 0.95 },
    { "text": "another line with [unclear] word", "confidence": 0.62 }
  ]
}''';
  }

  /// Parses the structured JSON response from the LLM and calculates
  /// a real confidence score based on per-line averages and [unclear] penalties.
  OCRResult _parseStructuredResponse(String rawResponse, String language) {
    try {
      // Strip markdown code fences if the LLM included them anyway
      final cleaned = rawResponse
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final Map<String, dynamic> parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      final List<dynamic> lines = parsed['lines'] as List<dynamic>? ?? [];

      if (lines.isEmpty) {
        return OCRResult(text: '', language: language, confidence: 0.0);
      }

      final List<String> textLines = [];
      double confidenceSum = 0.0;

      for (final line in lines) {
        final lineMap = line as Map<String, dynamic>;
        final text = (lineMap['text'] as String?) ?? '';
        final confidence = (lineMap['confidence'] as num?)?.toDouble() ?? 0.0;
        textLines.add(text);
        confidenceSum += confidence.clamp(0.0, 1.0);
      }

      final rawAvgConfidence = confidenceSum / lines.length;

      // Count [unclear] tokens and total words for penalty calculation
      final fullText = textLines.join('\n');
      final totalWords = fullText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      final unclearCount = RegExp(r'\[unclear\]', caseSensitive: false)
          .allMatches(fullText)
          .length;

      // Penalty: each [unclear] word reduces confidence proportionally (max 40% total penalty)
      final penalty = totalWords > 0
          ? ((unclearCount / totalWords) * 0.4).clamp(0.0, 0.4)
          : 0.0;

      final finalConfidence = (rawAvgConfidence - penalty).clamp(0.0, 1.0);

      return OCRResult(
        text: fullText,
        language: language,
        confidence: finalConfidence,
      );
    } catch (_) {
      // Fallback: if JSON parsing fails, treat the raw response as plain text
      // and assign a low confidence to signal the structured parse failed.
      final fallbackText = rawResponse.trim();
      final unclearCount = RegExp(r'\[unclear\]', caseSensitive: false)
          .allMatches(fallbackText)
          .length;
      final totalWords = fallbackText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      final penalty = totalWords > 0
          ? ((unclearCount / totalWords) * 0.4).clamp(0.0, 0.4)
          : 0.0;
      // Base confidence of 0.70 as fallback (LLM responded but JSON was malformed)
      final fallbackConfidence = (0.70 - penalty).clamp(0.0, 1.0);

      return OCRResult(
        text: fallbackText,
        language: language,
        confidence: fallbackConfidence,
      );
    }
  }
}
