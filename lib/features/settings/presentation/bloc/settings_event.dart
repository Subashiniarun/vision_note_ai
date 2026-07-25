part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
  @override
  List<Object> get props => [];
}

class UpdateTheme extends SettingsEvent {
  final String mode;
  const UpdateTheme(this.mode);
  @override
  List<Object> get props => [mode];
}

class UpdateOCRLanguage extends SettingsEvent {
  final String language;
  const UpdateOCRLanguage(this.language);
  @override
  List<Object> get props => [language];
}

class UpdateAIProvider extends SettingsEvent {
  final String provider;
  final String model;
  const UpdateAIProvider(this.provider, {this.model = ''});
  @override
  List<Object> get props => [provider, model];
}

class UpdateAIKey extends SettingsEvent {
  final String provider;
  final String key;
  const UpdateAIKey(this.provider, this.key);
  @override
  List<Object> get props => [provider, key];
}

class UpdateImageQuality extends SettingsEvent {
  final int quality;
  const UpdateImageQuality(this.quality);
  @override
  List<Object> get props => [quality];
}

class UpdateCompression extends SettingsEvent {
  final bool enabled;
  const UpdateCompression(this.enabled);
  @override
  List<Object> get props => [enabled];
}

class UpdateDefaultExport extends SettingsEvent {
  final String format;
  const UpdateDefaultExport(this.format);
  @override
  List<Object> get props => [format];
}

class UpdateAutoCapture extends SettingsEvent {
  final bool enabled;
  const UpdateAutoCapture(this.enabled);
  @override
  List<Object> get props => [enabled];
}

class UpdateAutoEnhance extends SettingsEvent {
  final bool enabled;
  const UpdateAutoEnhance(this.enabled);
  @override
  List<Object> get props => [enabled];
}

class CompleteOnboarding extends SettingsEvent {
  const CompleteOnboarding();
  @override
  List<Object> get props => [];
}
