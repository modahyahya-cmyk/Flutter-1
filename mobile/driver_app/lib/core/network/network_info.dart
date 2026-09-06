import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;

  Future<List<ConnectivityResult>> get currentConnectivity;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({required this.connectivity, required this.internetChecker});

  final Connectivity connectivity;
  final InternetConnectionChecker internetChecker;

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none)) return false;
    return internetChecker.hasConnection;
  }

  @override
  Future<List<ConnectivityResult>> get currentConnectivity async {
    return connectivity.checkConnectivity();
  }
}
