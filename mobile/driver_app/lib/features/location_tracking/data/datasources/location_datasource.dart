import 'package:geolocator/geolocator.dart';

import '../../../../core/errors/exceptions.dart';

class LocationDataSourceImpl {
  LocationDataSourceImpl({required this.geolocator});

  final GeolocatorPlatform geolocator;

  Future<bool> ensurePermissions() async {
    final serviceEnabled = await geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const AppException(message: 'Location services are disabled');
    }

    var permission = await geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw const AppException(message: 'Location permission not granted');
    }
    return true;
  }

  Future<Position> getCurrentPosition() async {
    await ensurePermissions();
    return geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Stream<Position> positionStream({
    Duration interval = const Duration(seconds: 15),
    double distanceFilter = 10,
  }) {
    final settings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilter.toInt(),
      intervalDuration: interval,
    );
    return geolocator.getPositionStream(locationSettings: settings);
  }

  double distanceInKm(double startLat, double startLng, double endLat, double endLng) {
    return geolocator.distanceBetween(startLat, startLng, endLat, endLng) / 1000;
  }
}
