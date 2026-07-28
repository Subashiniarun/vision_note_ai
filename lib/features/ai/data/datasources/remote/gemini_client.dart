import 'dart:convert';
import 'dart:typed_data';
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
      ':generateContent',
    );

    final response = await _apiClient.post(
      url,
      headers: {'X-Goog-Api-Key': apiKey},
      body: {
        'system_instruction': {
          'parts': [
            {'text': systemPrompt},
          ],
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': userPrompt},
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
            as String? ??
        '';
  }

  Future<String> transcribeImage({
    required String prompt,
    required Uint8List imageBytes,
    required String mimeType,
    String? model,
    double temperature = 0.1,
  }) async {
    final apiKey = await _secureStorage.getGeminiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw AIException('Gemini API key not configured');
    }

    final url = Uri.parse(
      '${ApiConstants.geminiBaseUrl}/${model ?? 'gemini-2.0-flash'}'
      ':generateContent',
    );

    final response = await _apiClient.post(
      url,
      headers: {'X-Goog-Api-Key': apiKey},
      body: {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt},
              {
                'inlineData': {
                  'mimeType': mimeType,
                  'data': base64Encode(imageBytes),
                },
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': temperature,
          'maxOutputTokens': 4096,
        },
      },
    );

    return response['candidates']?[0]?['content']?['parts']?[0]?['text']
            as String? ??
        '';
  }
}
