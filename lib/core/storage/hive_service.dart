import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static HiveService? _instance;

  static Future<HiveService> initialize() async {
    if (_instance != null) return _instance!;
    await Hive.initFlutter();
    _instance = HiveService._();
    return _instance!;
  }

  HiveService._();

  Future<Box<T>> openBox<T>(String name) async {
    return await Hive.openBox<T>(name);
  }
}
