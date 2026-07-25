import 'dart:convert';
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
}
