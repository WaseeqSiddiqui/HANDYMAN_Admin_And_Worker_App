import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkService {
  // Singleton pattern
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker =
      InternetConnectionChecker.instance;

  // Stream controller to broadcast connection status true = connected, false = disconnected
  final StreamController<bool> _connectionStreamController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionStreamController.stream;

  void initialize() {
    // Listen to connectivity changes (WiFi, Mobile, None)
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _checkInternetConnection(results);
    });

    // Initial check
    _connectivity.checkConnectivity().then(
      (results) => _checkInternetConnection(results),
    );
  }

  Future<void> _checkInternetConnection(
    List<ConnectivityResult> results,
  ) async {
    // connectivity_plus 6.0 returns a List<ConnectivityResult>
    // If list contains only none, we are definitely offline
    if (results.contains(ConnectivityResult.none) && results.length == 1) {
      _connectionStreamController.add(false);
      return;
    }

    // Even if we have WiFi/Mobile, we might not have internet. Check with checker.
    bool hasConnection = await _internetChecker.hasConnection;
    _connectionStreamController.add(hasConnection);
  }

  void dispose() {
    _connectionStreamController.close();
  }
}
