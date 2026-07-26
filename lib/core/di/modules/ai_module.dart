import 'package:injectable/injectable.dart';
import '../../../features/ai/data/datasources/remote/gemini_client.dart';
import '../../../features/ai/data/datasources/remote/openai_client.dart';
import '../../../features/ocr/data/datasources/local/ocr_engine.dart';
import '../../../features/settings/data/datasources/local/settings_cache.dart';
import '../../network/api_client.dart';
import '../../storage/secure_storage_service.dart';

@module
abstract class AiModule {
  @lazySingleton
  GeminiClient geminiClient(ApiClient api, SecureStorageService storage) =>
      GeminiClient(api, storage);

  @lazySingleton
  OpenAIClient openAIClient(ApiClient api, SecureStorageService storage) =>
      OpenAIClient(api, storage);

  @lazySingleton
  OCREngine ocrEngine() => OCREngine();

  @lazySingleton
  SettingsCache settingsCache() => SettingsCache();
}
