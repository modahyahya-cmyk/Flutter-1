import 'package:connectivity_plus/connectivity_plus.dart';

/// Connectivity contract used by repositories.
///
/// This class checks whether the device has an available network transport.
/// The actual API request remains responsible for detecting real internet/API
/// availability through Dio.
abstract class NetworkInfo {
  Future<bool> get isConnected;

  Future<List<ConnectivityResult>> get currentConnectivity;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({required this.connectivity});

  final Connectivity connectivity;

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();

    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn ||
          result == ConnectivityResult.bluetooth ||
          result == ConnectivityResult.other,
    );
  }

  @override
  Future<List<ConnectivityResult>> get currentConnectivity async {
    return connectivity.checkConnectivity();
  }
}
