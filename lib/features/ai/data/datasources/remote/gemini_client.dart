import 'dart:convert';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/storage/secure_storage_service.dart';

class GeminiClient {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  GeminiClient(this._apiClient, this._secureStorage);

  Future<String> sendPrompt({
    required String systemPrompt,
    required String userPrompt,
    String? model,
    double temperature = 0.3,
    int maxTokens = 2048,
  }) async {
    final apiKey = await _secureStorage.getGeminiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw AIException('Gemini API key not configured');
    }

    final url = Uri.parse(
      '${ApiConstants.geminiBaseUrl}/${model ?? ApiConstants.geminiDefaultModel}'
      ':generateContent?key=$apiKey',
    );

    final response = await _apiClient.post(
      url,
      body: {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': '$systemPrompt\n\n$userPrompt'},
            ],
          },
        ],
        'generationConfig': {
          'temperature': temperature,
          'maxOutputTokens': maxTokens,
        },
      },
    );

    return response['candidates']?[0]?['content']?['parts']?[0]?['text']
        as String? ?? '';
  }
}
