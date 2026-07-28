import 'package:hive/hive.dart';
import '../../../domain/entities/app_settings.dart';

class SettingsCache {
  static const _boxName = 'visionnote_settings';
  Box? _box;

  Future<void> _ensureOpen() async {
    if (_box != null) return;
    _box = await Hive.openBox(_boxName);
  }

  Future<AppSettings> load() async {
    await _ensureOpen();
    final box = _box!;
    return AppSettings(
      themeMode: box.get('theme_mode', defaultValue: 'system') as String,
      ocrLanguage: box.get('ocr_language', defaultValue: 'en') as String,
      aiProvider: box.get('ai_provider', defaultValue: 'gemini') as String,
      aiModel: box.get('ai_model', defaultValue: '') as String,
      imageQuality: box.get('image_quality', defaultValue: 85) as int,
      compressionEnabled: box.get('compression_enabled', defaultValue: true) as bool,
      defaultExportFormat: box.get('default_export_format', defaultValue: 'markdown') as String,
      autoExportPdf: box.get('auto_export_pdf', defaultValue: true) as bool,
      saveAsMarkdown: box.get('save_as_markdown', defaultValue: false) as bool,
      autoCapture: box.get('auto_capture', defaultValue: true) as bool,
      autoEnhance: box.get('auto_enhance', defaultValue: true) as bool,
      onboardingComplete: box.get('onboarding_complete', defaultValue: false) as bool,
    );
  }

  Future<void> save(AppSettings settings) async {
    await _ensureOpen();
    final box = _box!;
    await box.put('theme_mode', settings.themeMode);
    await box.put('ocr_language', settings.ocrLanguage);
    await box.put('ai_provider', settings.aiProvider);
    await box.put('ai_model', settings.aiModel);
    await box.put('image_quality', settings.imageQuality);
    await box.put('compression_enabled', settings.compressionEnabled);
    await box.put('default_export_format', settings.defaultExportFormat);
    await box.put('auto_export_pdf', settings.autoExportPdf);
    await box.put('save_as_markdown', settings.saveAsMarkdown);
    await box.put('auto_capture', settings.autoCapture);
    await box.put('auto_enhance', settings.autoEnhance);
    await box.put('onboarding_complete', settings.onboardingComplete);
  }
}
