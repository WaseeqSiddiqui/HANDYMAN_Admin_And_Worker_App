import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  // Singleton pattern
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isChecking = false;

  // Stream controller to broadcast connection status: true = connected, false = disconnected
  final StreamController<bool> _connectionStreamController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionStreamController.stream;

  void initialize() {
    // Listen to connectivity changes (WiFi, Mobile, None, etc.)
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      checkRealInternet(results);
    });

    // Initial check
    _connectivity.checkConnectivity().then(checkRealInternet);

    // Periodic check every 30 seconds to ensure data package hasn't expired
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      final results = await _connectivity.checkConnectivity();
      checkRealInternet(results);
    });
  }

  /// Refined check: Verified Interface -> Verified Internet Flow
  Future<void> checkRealInternet(List<ConnectivityResult> results) async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final hasInterface = results.any((r) => r != ConnectivityResult.none);

      if (!hasInterface) {
        _connectionStreamController.add(false);
        return;
      }

      // Interface exists, now verify data flow
      // We use HEAD for minimal data usage
      final isOnline = await _verifyDataFlow();
      _connectionStreamController.add(isOnline);
    } finally {
      _isChecking = false;
    }
  }

  Future<bool> _verifyDataFlow() async {
    try {
      // Trying to reach multiple reliable hosts
      final hosts = ['https://www.google.com', 'https://www.cloudflare.com'];

      for (var host in hosts) {
        try {
          final response = await http
              .head(Uri.parse(host))
              .timeout(const Duration(seconds: 5));
          if (response.statusCode >= 200 && response.statusCode < 400) {
            return true;
          }
        } catch (_) {
          continue;
        }
      }
      return false;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _connectionStreamController.close();
  }
}
