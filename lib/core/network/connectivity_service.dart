import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/logger.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  final _controller = StreamController<bool>.broadcast();
  final _log = VNALogger.get('Connectivity');

  Stream<bool> get isOnline => _controller.stream;
  bool _currentStatus = true;
  bool get currentStatus => _currentStatus;

  ConnectivityService(this._connectivity) {
    _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      _currentStatus = online;
      _controller.add(online);
      _log.info('Connectivity changed: ${online ? "online" : "offline"}');
    });
  }

  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _currentStatus = results.any((r) => r != ConnectivityResult.none);
    _log.info('Initial connectivity: ${_currentStatus ? "online" : "offline"}');
  }

  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _currentStatus = results.any((r) => r != ConnectivityResult.none);
    return _currentStatus;
  }

  void dispose() {
    _controller.close();
  }
}
