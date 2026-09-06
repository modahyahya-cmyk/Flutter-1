import '../../../../core/network/network_info.dart';
import '../../../../core/storage/isar_service.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/background_location_service.dart';
import '../datasources/location_datasource.dart';
import 'package:latlong2/latlong.dart';

class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl({
    required this.locationDataSource,
    required this.backgroundService,
    required this.isarService,
    required this.networkInfo,
  });

  final LocationDataSourceImpl locationDataSource;
  final BackgroundLocationService backgroundService;
  final IsarService isarService;
  final NetworkInfo networkInfo;

  @override
  Future<bool> startTracking({String? deliveryId}) =>
      backgroundService.startTracking(deliveryId: deliveryId);

  @override
  Future<void> stopTracking() => backgroundService.stopTracking();

  @override
  Future<void> uploadPendingLocations() => backgroundService.uploadPendingLocations();

  @override
  Future<LatLng?> getCurrentLocation() async {
    try {
      final position = await locationDataSource.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  @override
  double distanceInKm(LatLng from, LatLng to) => backgroundService.calculateDistance(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude,
      );
}
