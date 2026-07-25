import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/i_settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final ISettingsRepository _settingsRepository;

  SettingsBloc(this._settingsRepository) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateTheme>(_onUpdateTheme);
    on<UpdateOCRLanguage>(_onUpdateOCRLanguage);
    on<UpdateAIProvider>(_onUpdateAIProvider);
    on<UpdateAIKey>(_onUpdateAIKey);
    on<UpdateImageQuality>(_onUpdateImageQuality);
    on<UpdateCompression>(_onUpdateCompression);
    on<UpdateDefaultExport>(_onUpdateDefaultExport);
    on<UpdateAutoCapture>(_onUpdateAutoCapture);
    on<UpdateAutoEnhance>(_onUpdateAutoEnhance);
    on<CompleteOnboarding>(_onCompleteOnboarding);
  }

  AppSettings _settings = const AppSettings();

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      _settings = await _settingsRepository.load();
      emit(SettingsLoaded(_settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _saveAndEmit(
    AppSettings updated,
    Emitter<SettingsState> emit,
  ) async {
    _settings = updated;
    await _settingsRepository.save(updated);
    emit(SettingsLoaded(updated));
  }

  Future<void> _onUpdateTheme(
    UpdateTheme event,
    Emitter<SettingsState> emit,
  ) async {
    await _saveAndEmit(_settings.copyWith(themeMode: event.mode), emit);
  }

  Future<void> _onUpdateOCRLanguage(
    UpdateOCRLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    await _saveAndEmit(_settings.copyWith(ocrLanguage: event.language), emit);
  }

  Future<void> _onUpdateAIProvider(
    UpdateAIProvider event,
    Emitter<SettingsState> emit,
  ) async {
    await _saveAndEmit(
      _settings.copyWith(aiProvider: event.provider, aiModel: event.model),
      emit,
    );
  }

  Future<void> _onUpdateAIKey(
    UpdateAIKey event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsSaving());
    try {
      await _settingsRepository.saveAiApiKey(event.provider, event.key);
      emit(SettingsLoaded(_settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateImageQuality(
    UpdateImageQuality event,
    Emitter<SettingsState> emit,
  ) async {
    await _saveAndEmit(
      _settings.copyWith(imageQuality: event.quality),
      emit,
    );
  }

  Future<void> _onUpdateCompression(
    UpdateCompression event,
    Emitter<SettingsState> emit,
  ) async {
    await _saveAndEmit(
      _settings.copyWith(compressionEnabled: event.enabled),
      emit,
    );
  }

  Future<void> _onUpdateDefaultExport(
    UpdateDefaultExport event,
    Emitter<SettingsState> emit,
  ) async {
    await _saveAndEmit(
      _settings.copyWith(defaultExportFormat: event.format),
      emit,
    );
  }

  Future<void> _onUpdateAutoCapture(
    UpdateAutoCapture event,
    Emitter<SettingsState> emit,
  ) async {
    await _saveAndEmit(
      _settings.copyWith(autoCapture: event.enabled),
      emit,
    );
  }

  Future<void> _onUpdateAutoEnhance(
    UpdateAutoEnhance event,
    Emitter<SettingsState> emit,
  ) async {
    await _saveAndEmit(
      _settings.copyWith(autoEnhance: event.enabled),
      emit,
    );
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<SettingsState> emit,
  ) async {
    await _saveAndEmit(
      _settings.copyWith(onboardingComplete: true),
      emit,
    );
  }
}
