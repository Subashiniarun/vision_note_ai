import 'dart:convert';
import 'dart:typed_data';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/storage/secure_storage_service.dart';

class OpenAIClient {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  OpenAIClient(this._apiClient, this._secureStorage);

  Future<String> sendPrompt({
    required String systemPrompt,
    required String userPrompt,
    String? model,
    double temperature = 0.3,
    int maxTokens = 2048,
  }) async {
    final apiKey = await _secureStorage.getOpenAIKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw AIException('OpenAI API key not configured');
    }

    final url = Uri.parse('${ApiConstants.openaiBaseUrl}/chat/completions');

    final response = await _apiClient.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
      body: {
        'model': model ?? ApiConstants.openaiDefaultModel,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'temperature': temperature,
        'max_tokens': maxTokens,
      },
    );

    return response['choices']?[0]?['message']?['content'] as String? ?? '';
  }

  Future<String> transcribeImage({
    required String systemPrompt,
    required Uint8List imageBytes,
    required String mimeType,
    String? model,
    double temperature = 0.1,
  }) async {
    final apiKey = await _secureStorage.getOpenAIKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw AIException('OpenAI API key not configured');
    }

    final base64 = base64Encode(imageBytes);
    final url = Uri.parse('${ApiConstants.openaiBaseUrl}/chat/completions');

    final response = await _apiClient.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
      body: {
        'model': model ?? 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': 'Transcribe the handwriting in this image exactly as written.'},
              {
                'type': 'image_url',
                'image_url': {'url': 'data:$mimeType;base64,$base64'},
              },
            ],
          },
        ],
        'temperature': temperature,
        'max_tokens': 4096,
      },
    );

    return response['choices']?[0]?['message']?['content'] as String? ?? '';
  }
}
