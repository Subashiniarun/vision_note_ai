import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  Stream<bool> get isOnline => _controller.stream;
  bool _currentStatus = true;
  bool get currentStatus => _currentStatus;

  ConnectivityService(this._connectivity) {
    _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      _currentStatus = online;
      _controller.add(online);
    });
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
