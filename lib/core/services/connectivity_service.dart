import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  Future<ConnectivityService> init() async {
    final initial = await _connectivity.checkConnectivity();
    _updateStatus(initial);
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
    return this;
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final connected = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    isConnected.value = connected;
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
