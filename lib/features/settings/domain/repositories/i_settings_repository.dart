import '../entities/app_settings.dart';

abstract class ISettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
  Future<String?> getAiApiKey(String provider);
  Future<void> saveAiApiKey(String provider, String key);
}
