import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  static Future<bool> requestStorage() async {
    if (await Permission.storage.isGranted) return true;
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }
}
