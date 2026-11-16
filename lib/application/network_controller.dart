import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkStatus {
  const NetworkStatus({this.connected = true});
  final bool connected;
  bool get online => connected;
}

final networkProvider = StateNotifierProvider<NetworkController, NetworkStatus>(
  (ref) => NetworkController(),
);

class NetworkController extends StateNotifier<NetworkStatus> {
  NetworkController.detached() : super(const NetworkStatus());
  NetworkController() : super(const NetworkStatus()) {
    _subscription = _connectivity.onConnectivityChanged.listen(_changed);
    unawaited(_initialize());
  }
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _stableConnection;
  Future<void> _initialize() async {
    try {
      _changed(await _connectivity.checkConnectivity());
    } catch (_) {
      // Keep the last known state when the platform check fails.
    }
  }

  void _changed(List<ConnectivityResult> results) {
    _stableConnection?.cancel();
    final connected = results.any((e) => e != ConnectivityResult.none);
    if (!connected) {
      state = const NetworkStatus(connected: false);
      return;
    }
    _stableConnection = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        state = const NetworkStatus();
      }
    });
  }

  @override
  void dispose() {
    _stableConnection?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
