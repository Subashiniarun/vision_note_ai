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
    final mimeType = 'image/jpeg';
    final prompt = _buildPrompt(language);

    String text;
    if (settings.aiProvider == 'openai') {
      text = await _openAIClient.transcribeImage(
        systemPrompt: prompt,
        imageBytes: imageBytes,
        mimeType: mimeType,
        model: settings.aiModel.isNotEmpty ? settings.aiModel : null,
      );
    } else {
      text = await _geminiClient.transcribeImage(
        prompt: prompt,
        imageBytes: imageBytes,
        mimeType: mimeType,
        model: settings.aiModel.isNotEmpty ? settings.aiModel : null,
      );
    }

    return OCRResult(
      text: text,
      language: language,
      confidence: 0.95,
    );
  }

  String _buildPrompt(String language) {
    final lang = language == 'en' ? 'English' : language;
    return 'You are a handwriting recognition engine. '
        'Transcribe the handwritten text in this image precisely as written. '
        'Output ONLY the transcribed text, no explanations or formatting. '
        'Language: $lang. '
        'If you cannot read a word, write [unclear] in its place.';
  }
}
