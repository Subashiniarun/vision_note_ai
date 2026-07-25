import 'package:hive/hive.dart';
import '../../../domain/entities/app_settings.dart';

class SettingsCache {
  static const _boxName = 'visionnote_settings';
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  AppSettings load() {
    return AppSettings(
      themeMode: _box.get('theme_mode', defaultValue: 'system') as String,
      ocrLanguage: _box.get('ocr_language', defaultValue: 'en') as String,
      aiProvider: _box.get('ai_provider', defaultValue: 'gemini') as String,
      aiModel: _box.get('ai_model', defaultValue: '') as String,
      imageQuality:
          _box.get('image_quality', defaultValue: 90) as int,
      compressionEnabled:
          _box.get('compression_enabled', defaultValue: true) as bool,
      defaultExportFormat:
          _box.get('default_export_format', defaultValue: 'markdown') as String,
      autoCapture:
          _box.get('auto_capture', defaultValue: true) as bool,
      autoEnhance:
          _box.get('auto_enhance', defaultValue: true) as bool,
      onboardingComplete:
          _box.get('onboarding_complete', defaultValue: false) as bool,
    );
  }

  Future<void> save(AppSettings settings) async {
    await _box.put('theme_mode', settings.themeMode);
    await _box.put('ocr_language', settings.ocrLanguage);
    await _box.put('ai_provider', settings.aiProvider);
    await _box.put('ai_model', settings.aiModel);
    await _box.put('image_quality', settings.imageQuality);
    await _box.put('compression_enabled', settings.compressionEnabled);
    await _box.put('default_export_format', settings.defaultExportFormat);
    await _box.put('auto_capture', settings.autoCapture);
    await _box.put('auto_enhance', settings.autoEnhance);
    await _box.put('onboarding_complete', settings.onboardingComplete);
  }
}
