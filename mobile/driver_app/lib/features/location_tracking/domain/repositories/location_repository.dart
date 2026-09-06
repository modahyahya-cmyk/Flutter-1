import 'package:latlong2/latlong.dart';

abstract class LocationRepository {
  Future<bool> startTracking({String? deliveryId});
  Future<void> stopTracking();
  Future<void> uploadPendingLocations();
  Future<LatLng?> getCurrentLocation();
  double distanceInKm(LatLng from, LatLng to);
}
