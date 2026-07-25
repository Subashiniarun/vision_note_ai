class AppConstants {
  static const String appName = 'VisionNote AI';
  static const String appVersion = '1.0.0';
  static const String defaultTitle = 'Untitled';
  static const String defaultOcrLanguage = 'en';
  static const int defaultImageQuality = 90;
  static const int maxRecentScans = 50;
  static const int autoCaptureStableMs = 500;
  static const double autoCaptureMinArea = 0.3;
  static const int maxAiRetries = 3;
  static const Duration aiRetryDelay = Duration(seconds: 2);
  static const int maxFlashcardsPerDoc = 10;
  static const String dbFileName = 'visionnote.db';
  static const String hiveBoxName = 'visionnote_settings';
}
