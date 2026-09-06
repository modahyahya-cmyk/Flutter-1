import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/isar_service.dart';
import '../../../../core/storage/models/location_log_model.dart';
import '../../../../core/utils/logger.dart';

class BackgroundLocationService {
  final IsarService isarService;
  final ApiClient apiClient;
  final NetworkInfo networkInfo;

  Timer? _upstreamTimer;
  StreamSubscription<Position>? _positionStream;
  bool _isTracking = false;
  String? _currentDeliveryId;

  final Battery _battery = Battery();

  BackgroundLocationService({
    required this.isarService,
    required this.apiClient,
    required this.networkInfo,
  });

  bool get isTracking => _isTracking;
  String? get currentDeliveryId => _currentDeliveryId;

  // =========================================================================
  // START / STOP TRACKING
  // =========================================================================

  Future<bool> startTracking({String? deliveryId}) async {
    if (_isTracking) {
      AppLogger.warning('Location tracking already active');
      return false;
    }

    try {
      final hasPermission = await ensurePermissions();
      if (!hasPermission) return false;

      _currentDeliveryId = deliveryId;
      _isTracking = true;

      _startPositionStream();
      _startPeriodicUpload();

      AppLogger.info('Background location tracking started', data: {'delivery_id': deliveryId});
      return true;
    } catch (e) {
      AppLogger.error('Failed to start location tracking', error: e);
      _isTracking = false;
      return false;
    }
  }

  Future<void> stopTracking() async {
    if (!_isTracking) return;

    try {
      await _positionStream?.cancel();
      _upstreamTimer?.cancel();

      _positionStream = null;
      _upstreamTimer = null;
      _isTracking = false;
      _currentDeliveryId = null;

      await _uploadPendingLocations();
      AppLogger.info('Background location tracking stopped');
    } catch (e) {
      AppLogger.error('Error stopping location tracking', error: e);
    }
  }

  // =========================================================================
  // POSITION STREAM
  // =========================================================================

  void _startPositionStream() {
    final settings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      intervalDuration: AppConfig.LOCATION_UPDATE_INTERVAL,
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationText: 'Tracking your delivery location',
        notificationTitle: '${AppConfig.APP_NAME} — Location Tracking',
        enableWakeLock: true,
      ),
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: settings).listen(
      (position) => _handleNewPosition(position),
      onError: (error) => AppLogger.error('Position stream error', error: error),
    );
  }

  Future<void> _handleNewPosition(Position position) async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;

      final locationLog = LocationLogModel(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: DateTime.now(),
        deliveryId: _currentDeliveryId,
        isUploaded: false,
        batteryLevel: '$batteryLevel%',
        isCharging: batteryState == BatteryState.charging,
      );

      await isarService.saveLocationLog(locationLog);

      AppLogger.debug('Location logged', data: {
        'lat': position.latitude,
        'lng': position.longitude,
        'accuracy': position.accuracy,
        'delivery_id': _currentDeliveryId,
      });
    } catch (e) {
      AppLogger.error('Failed to handle new position', error: e);
    }
  }

  // =========================================================================
  // PERIODIC UPLOAD
  // =========================================================================

  void _startPeriodicUpload() {
    _upstreamTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      await _uploadPendingLocations();
    });
  }

  Future<void> uploadPendingLocations() => _uploadPendingLocations();

  Future<void> _uploadPendingLocations() async {
    try {
      if (!await networkInfo.isConnected) {
        AppLogger.debug('No internet connection, skipping location upload');
        return;
      }

      final locations = await isarService.getUnuploadedLocations();
      if (locations.isEmpty) {
        AppLogger.debug('No pending locations to upload');
        return;
      }

      AppLogger.debug('Uploading ${locations.length} location points');

      const batchSize = 100;
      for (var i = 0; i < locations.length; i += batchSize) {
        final end = i + batchSize > locations.length ? locations.length : i + batchSize;
        final batch = locations.sublist(i, end);

        try {
          final payload = batch.map((loc) => loc.toJson()).toList();
          await apiClient.post('/driver/location/batch', data: {'locations': payload});

          final ids = batch.map((loc) => loc.id).toList();
          await isarService.markLocationsAsUploaded(ids);

          AppLogger.debug('Uploaded batch of ${batch.length} locations');
        } catch (e) {
          AppLogger.error('Failed to upload location batch', error: e);
        }
      }

      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      await isarService.deleteOldLocationLogs(sevenDaysAgo);
    } catch (e) {
      AppLogger.error('Error in periodic location upload', error: e);
    }
  }

  // =========================================================================
  // PERMISSIONS
  // =========================================================================

  Future<bool> ensurePermissions() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        AppLogger.error('Location services are disabled');
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }
      if (permission == LocationPermission.deniedForever) return false;

      // Upgrade while-in-use to always for background tracking (Android 10+).
      if (permission == LocationPermission.whileInUse) {
        permission = await Geolocator.requestPermission();
      }

      return true;
    } catch (e) {
      AppLogger.error('Error checking permissions', error: e);
      return false;
    }
  }

  // =========================================================================
  // CURRENT LOCATION
  // =========================================================================

  Future<Position?> getCurrentLocation() async {
    try {
      if (!await ensurePermissions()) return null;
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      AppLogger.error('Failed to get current location', error: e);
      return null;
    }
  }

  // =========================================================================
  // DISTANCE CALCULATION
  // =========================================================================

  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) / 1000;
  }
}
