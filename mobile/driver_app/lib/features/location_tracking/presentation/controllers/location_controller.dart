import 'package:get/get.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/usecases/start_tracking_usecase.dart';
import '../../domain/usecases/stop_tracking_usecase.dart';
import '../../domain/usecases/upload_location_usecase.dart';

class LocationController extends GetxController {
  LocationController({
    required this.startTrackingUseCase,
    required this.stopTrackingUseCase,
    required this.uploadLocationUseCase,
  });

  final StartTrackingUseCase startTrackingUseCase;
  final StopTrackingUseCase stopTrackingUseCase;
  final UploadLocationUseCase uploadLocationUseCase;

  bool isTracking = false;
  String activeDeliveryId = '';
  int pointCount = 0;
  final RxString error = ''.obs;

  Future<void> startTracking({String? deliveryId}) async {
    final result = await startTrackingUseCase(StartTrackingParams(deliveryId: deliveryId));
    result.fold<bool>(
      (failure) {
        error.value = failure.message;
        AppLogger.error('Failed to start tracking: ${failure.message}');
        return false;
      },
      (started) {
        isTracking = started;
        if (started) {
          activeDeliveryId = deliveryId ?? '';
          error.value = '';
          AppLogger.info('Location tracking active for delivery: $deliveryId');
        }
        return started;
      },
    );
  }

  Future<void> stopTracking() async {
    final result = await stopTrackingUseCase(StopTrackingParams());
    result.fold<void>(
      (failure) => AppLogger.error('Failed to stop tracking: ${failure.message}'),
      (_) {
        isTracking = false;
        activeDeliveryId = '';
        AppLogger.info('Location tracking stopped');
      },
    );
  }

  Future<void> uploadPending() async {
    final result = await uploadLocationUseCase(UploadLocationParams());
    result.fold<void>(
      (failure) => AppLogger.warning('Location upload failed: ${failure.message}'),
      (_) {
        pointCount = 0;
        AppLogger.debug('Pending locations uploaded');
      },
    );
  }
}
