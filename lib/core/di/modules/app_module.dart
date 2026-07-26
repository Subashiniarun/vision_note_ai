import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import '../../database/app_database.dart';
import '../../network/api_client.dart';
import '../../network/connectivity_service.dart';
import '../../storage/file_storage.dart';
import '../../storage/secure_storage_service.dart';

@module
abstract class AppModule {
  @preResolve
  @lazySingleton
  Future<AppDatabase> get database async {
    final db = AppDatabase();
    await db.init();
    return db;
  }

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  SecureStorageService get secureStorageService =>
      SecureStorageService(secureStorage);

  @lazySingleton
  FileStorage get fileStorage => FileStorage();

  @lazySingleton
  http.Client get httpClient => http.Client();

  @lazySingleton
  ApiClient get apiClient => ApiClient(httpClient);

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @preResolve
  @lazySingleton
  Future<ConnectivityService> get connectivityService async {
    final service = ConnectivityService(connectivity);
    await service.initialize();
    return service;
  }
}
