import 'package:injectable/injectable.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../datasources/local/settings_cache.dart';
import '../../../../core/storage/secure_storage_service.dart';

@Injectable(as: ISettingsRepository)
class SettingsRepository implements ISettingsRepository {
  final SettingsCache _cache;
  final SecureStorageService _secureStorage;

  SettingsRepository(this._cache, this._secureStorage);

  @override
  Future<AppSettings> load() async {
    return _cache.load();
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _cache.save(settings);
  }

  @override
  Future<String?> getAiApiKey(String provider) async {
    if (provider == 'openai') {
      return await _secureStorage.getOpenAIKey();
    }
    return await _secureStorage.getGeminiKey();
  }

  @override
  Future<void> saveAiApiKey(String provider, String key) async {
    if (provider == 'openai') {
      await _secureStorage.saveOpenAIKey(key);
    } else {
      await _secureStorage.saveGeminiKey(key);
    }
  }
}
