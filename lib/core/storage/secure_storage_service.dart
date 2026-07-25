import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const _geminiKey = 'gemini_api_key';
  static const _openaiKey = 'openai_api_key';

  Future<void> saveGeminiKey(String key) =>
      _storage.write(key: _geminiKey, value: key);

  Future<String?> getGeminiKey() => _storage.read(key: _geminiKey);

  Future<void> saveOpenAIKey(String key) =>
      _storage.write(key: _openaiKey, value: key);

  Future<String?> getOpenAIKey() => _storage.read(key: _openaiKey);

  Future<void> clearAllKeys() async {
    await _storage.delete(key: _geminiKey);
    await _storage.delete(key: _openaiKey);
  }
}
