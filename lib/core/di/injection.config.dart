// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/ai/data/datasources/remote/gemini_client.dart' as _i734;
import '../../features/ai/data/datasources/remote/openai_client.dart' as _i258;
import '../../features/ai/data/repositories/ai_repository.dart' as _i238;
import '../../features/ai/domain/repositories/i_ai_repository.dart' as _i26;
import '../../features/ai/presentation/bloc/ai_bloc.dart' as _i491;
import '../../features/camera/presentation/bloc/camera_bloc.dart' as _i702;
import '../../features/export/data/repositories/export_repository.dart'
    as _i823;
import '../../features/export/domain/repositories/i_export_repository.dart'
    as _i976;
import '../../features/export/presentation/bloc/export_bloc.dart' as _i872;
import '../../features/history/presentation/bloc/history_bloc.dart' as _i1070;
import '../../features/image_process/data/repositories/image_processor.dart'
    as _i417;
import '../../features/image_process/domain/repositories/i_image_processor.dart'
    as _i274;
import '../../features/image_process/presentation/bloc/image_process_bloc.dart'
    as _i836;
import '../../features/ocr/data/datasources/local/ocr_engine.dart' as _i775;
import '../../features/ocr/data/repositories/ocr_repository.dart' as _i140;
import '../../features/ocr/domain/repositories/i_ocr_repository.dart' as _i315;
import '../../features/ocr/presentation/bloc/ocr_bloc.dart' as _i300;
import '../../features/scan/data/datasources/local/scan_local_datasource.dart'
    as _i242;
import '../../features/scan/data/repositories/scan_repository.dart' as _i179;
import '../../features/scan/domain/repositories/i_scan_repository.dart'
    as _i466;
import '../../features/scan/domain/usecases/delete_scan.dart' as _i766;
import '../../features/scan/domain/usecases/get_recent_scans.dart' as _i679;
import '../../features/scan/domain/usecases/save_scan.dart' as _i273;
import '../../features/scan/domain/usecases/search_scans.dart' as _i765;
import '../../features/scan/presentation/bloc/scan_bloc.dart' as _i917;
import '../../features/settings/data/datasources/local/settings_cache.dart'
    as _i207;
import '../../features/settings/data/repositories/settings_repository.dart'
    as _i450;
import '../../features/settings/domain/repositories/i_settings_repository.dart'
    as _i657;
import '../../features/settings/presentation/bloc/settings_bloc.dart' as _i585;
import '../database/app_database.dart' as _i982;
import '../network/api_client.dart' as _i557;
import '../network/connectivity_service.dart' as _i491;
import '../storage/file_storage.dart' as _i730;
import '../storage/secure_storage_service.dart' as _i666;
import 'modules/ai_module.dart' as _i581;
import 'modules/app_module.dart' as _i349;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final aiModule = _$AiModule();
  final appModule = _$AppModule();
  gh.lazySingleton<_i775.OCREngine>(() => aiModule.ocrEngine());
  gh.lazySingleton<_i207.SettingsCache>(() => aiModule.settingsCache());
  await gh.lazySingletonAsync<_i982.AppDatabase>(
    () => appModule.database,
    preResolve: true,
  );
  gh.lazySingleton<_i558.FlutterSecureStorage>(() => appModule.secureStorage);
  gh.lazySingleton<_i666.SecureStorageService>(
    () => appModule.secureStorageService,
  );
  gh.lazySingleton<_i730.FileStorage>(() => appModule.fileStorage);
  gh.lazySingleton<_i519.Client>(() => appModule.httpClient);
  gh.lazySingleton<_i557.ApiClient>(() => appModule.apiClient);
  gh.lazySingleton<_i895.Connectivity>(() => appModule.connectivity);
  gh.lazySingleton<_i491.ConnectivityService>(
    () => appModule.connectivityService,
  );
  gh.factory<_i976.IExportRepository>(
    () => _i823.ExportRepository(gh<_i730.FileStorage>()),
  );
  gh.factory<_i242.ScanLocalDataSource>(
    () => _i242.ScanLocalDataSource(gh<_i982.AppDatabase>()),
  );
  gh.factory<_i657.ISettingsRepository>(
    () => _i450.SettingsRepository(
      gh<_i207.SettingsCache>(),
      gh<_i666.SecureStorageService>(),
    ),
  );
  gh.factory<_i274.IImageProcessor>(() => _i417.ImageProcessor());
  gh.factory<_i872.ExportBloc>(
    () => _i872.ExportBloc(gh<_i976.IExportRepository>()),
  );
  gh.factory<_i702.CameraBloc>(
    () => _i702.CameraBloc(gh<_i274.IImageProcessor>()),
  );
  gh.factory<_i836.ImageProcessBloc>(
    () => _i836.ImageProcessBloc(gh<_i274.IImageProcessor>()),
  );
  gh.factory<_i315.IOCRRepository>(
    () => _i140.OCRRepository(gh<_i775.OCREngine>()),
  );
  gh.lazySingleton<_i734.GeminiClient>(
    () => aiModule.geminiClient(
      gh<_i557.ApiClient>(),
      gh<_i666.SecureStorageService>(),
    ),
  );
  gh.lazySingleton<_i258.OpenAIClient>(
    () => aiModule.openAIClient(
      gh<_i557.ApiClient>(),
      gh<_i666.SecureStorageService>(),
    ),
  );
  gh.factory<_i466.IScanRepository>(
    () => _i179.ScanRepository(gh<_i242.ScanLocalDataSource>()),
  );
  gh.factory<_i300.OCRBloc>(() => _i300.OCRBloc(gh<_i315.IOCRRepository>()));
  gh.factory<_i26.IAIRepository>(
    () => _i238.AIRepository(
      gh<_i734.GeminiClient>(),
      gh<_i258.OpenAIClient>(),
      gh<_i657.ISettingsRepository>(),
      gh<_i491.ConnectivityService>(),
    ),
  );
  gh.factory<_i585.SettingsBloc>(
    () => _i585.SettingsBloc(gh<_i657.ISettingsRepository>()),
  );
  gh.factory<_i491.AIBloc>(() => _i491.AIBloc(gh<_i26.IAIRepository>()));
  gh.factory<_i766.DeleteScan>(
    () => _i766.DeleteScan(gh<_i466.IScanRepository>()),
  );
  gh.factory<_i679.GetRecentScans>(
    () => _i679.GetRecentScans(gh<_i466.IScanRepository>()),
  );
  gh.factory<_i273.SaveScan>(() => _i273.SaveScan(gh<_i466.IScanRepository>()));
  gh.factory<_i765.SearchScans>(
    () => _i765.SearchScans(gh<_i466.IScanRepository>()),
  );
  gh.factory<_i1070.HistoryBloc>(
    () => _i1070.HistoryBloc(
      gh<_i679.GetRecentScans>(),
      gh<_i766.DeleteScan>(),
      gh<_i765.SearchScans>(),
      gh<_i273.SaveScan>(),
    ),
  );
  gh.factory<_i917.ScanBloc>(
    () => _i917.ScanBloc(
      gh<_i679.GetRecentScans>(),
      gh<_i273.SaveScan>(),
      gh<_i766.DeleteScan>(),
      gh<_i765.SearchScans>(),
    ),
  );
  return getIt;
}

class _$AiModule extends _i581.AiModule {}

class _$AppModule extends _i349.AppModule {}
