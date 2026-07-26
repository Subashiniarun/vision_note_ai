import 'package:logging/logging.dart' as logging;

class VNALogger {
  static bool _configured = false;

  static void configure({logging.Level minLevel = logging.Level.ALL}) {
    if (_configured) return;
    _configured = true;
    logging.hierarchicalLoggingEnabled = true;
    logging.Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print(
        '[${record.level.name}][${record.loggerName}] ${record.message}'
        '${record.error != null ? '\n  -> ${record.error}' : ''}',
      );
    });
    logging.Logger.root.level = minLevel;
  }

  static VNALogger get(String name) => VNALogger._(logging.Logger(name));

  final logging.Logger _inner;
  VNALogger._(this._inner);

  void info(String message) => _inner.info(message);
  void warning(String message, [Object? error]) => _inner.warning(message, error);
  void severe(String message, [Object? error]) => _inner.severe(message, error);
  void fine(String message) => _inner.fine(message);
}
