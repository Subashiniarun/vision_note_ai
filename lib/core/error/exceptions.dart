sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class DatabaseException extends AppException {
  const DatabaseException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class AIException extends AppException {
  const AIException(super.message);
}

class AIOfflineException extends AppException {
  const AIOfflineException() : super('No internet connection');
}

class OCRException extends AppException {
  const OCRException(super.message);
}

class ImageProcessException extends AppException {
  const ImageProcessException(super.message);
}

class CameraException extends AppException {
  const CameraException(super.message);
}

class StorageException extends AppException {
  const StorageException(super.message);
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException()
      : super('Camera permission is required');
}
