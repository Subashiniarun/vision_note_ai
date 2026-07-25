import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final String themeMode;
  final String ocrLanguage;
  final String aiProvider;
  final String aiModel;
  final int imageQuality;
  final bool compressionEnabled;
  final String defaultExportFormat;
  final bool autoCapture;
  final bool autoEnhance;
  final bool onboardingComplete;

  const AppSettings({
    this.themeMode = 'system',
    this.ocrLanguage = 'en',
    this.aiProvider = 'gemini',
    this.aiModel = '',
    this.imageQuality = 90,
    this.compressionEnabled = true,
    this.defaultExportFormat = 'markdown',
    this.autoCapture = true,
    this.autoEnhance = true,
    this.onboardingComplete = false,
  });

  AppSettings copyWith({
    String? themeMode,
    String? ocrLanguage,
    String? aiProvider,
    String? aiModel,
    int? imageQuality,
    bool? compressionEnabled,
    String? defaultExportFormat,
    bool? autoCapture,
    bool? autoEnhance,
    bool? onboardingComplete,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      ocrLanguage: ocrLanguage ?? this.ocrLanguage,
      aiProvider: aiProvider ?? this.aiProvider,
      aiModel: aiModel ?? this.aiModel,
      imageQuality: imageQuality ?? this.imageQuality,
      compressionEnabled: compressionEnabled ?? this.compressionEnabled,
      defaultExportFormat: defaultExportFormat ?? this.defaultExportFormat,
      autoCapture: autoCapture ?? this.autoCapture,
      autoEnhance: autoEnhance ?? this.autoEnhance,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        ocrLanguage,
        aiProvider,
        aiModel,
        imageQuality,
        compressionEnabled,
        defaultExportFormat,
        autoCapture,
        autoEnhance,
        onboardingComplete,
      ];
}
