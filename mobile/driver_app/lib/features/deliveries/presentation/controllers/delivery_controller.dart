import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/logger.dart';
import '../../../location_tracking/presentation/controllers/location_controller.dart';
import '../../domain/entities/delivery.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../../domain/usecases/accept_delivery_usecase.dart';
import '../../domain/usecases/complete_delivery_usecase.dart';
import '../../domain/usecases/get_deliveries_usecase.dart';
import '../../domain/usecases/sync_offline_deliveries_usecase.dart';

class DeliveryController extends GetxController {
  DeliveryController({
    required this.getDeliveriesUseCase,
    required this.acceptDeliveryUseCase,
    required this.completeDeliveryUseCase,
    required this.syncOfflineDeliveriesUseCase,
    required this.repository,
    required this.locationController,
  });

  final GetDeliveriesUseCase getDeliveriesUseCase;
  final AcceptDeliveryUseCase acceptDeliveryUseCase;
  final CompleteDeliveryUseCase completeDeliveryUseCase;
  final SyncOfflineDeliveriesUseCase syncOfflineDeliveriesUseCase;
  final DeliveryRepository repository;
  final LocationController locationController;

  final RxList<Delivery> deliveries = <Delivery>[].obs;
  final Rxn<Delivery> activeDelivery = Rxn<Delivery>();
  final RxBool isLoading = false.obs;
  final RxBool isSyncing = false.obs;
  final RxString error = ''.obs;
  final RxInt pendingSyncCount = 0.obs;
  final RxBool isOffline = false.obs;

  List<Delivery> get availableDeliveries => deliveries.where((d) => d.status == DeliveryStatus.assigned).toList();

  List<Delivery> get acceptedDeliveries => deliveries.where((d) => d.status == DeliveryStatus.accepted).toList();

  List<Delivery> get completedDeliveries => deliveries.where((d) => d.status == DeliveryStatus.delivered).toList();

  @override
  void onInit() {
    super.onInit();
    loadDeliveries();
    _startAutoRefresh();
    _startAutoSync();
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (!isClosed) {
        loadDeliveries(silent: true);
        _startAutoRefresh();
      }
    });
  }

  void _startAutoSync() {
    Future.delayed(const Duration(minutes: 2), () {
      if (!isClosed) {
        syncOfflineData();
        _startAutoSync();
      }
    });
  }

  Future<void> loadDeliveries({bool refresh = false, bool silent = false}) async {
    if (!silent) isLoading.value = true;
    error.value = '';

    final result = await getDeliveriesUseCase(GetDeliveriesParams(includeOffline: true));
    result.fold(
      (failure) {
        error.value = failure.message;
        AppLogger.error('Failed to load deliveries', data: {'error': failure.message});
      },
      (loaded) {
        deliveries.assignAll(loaded);
        isOffline.value = loaded.isNotEmpty && error.isNotEmpty;

        if (activeDelivery.value == null) {
          Delivery? active;
          for (final d in loaded) {
            if (d.status == DeliveryStatus.accepted ||
                d.status == DeliveryStatus.pickedUp ||
                d.status == DeliveryStatus.inTransit) {
              active = d;
              break;
            }
          }
          if (active != null) activeDelivery.value = active;
        }
      },
    );

    isLoading.value = false;
  }

  Future<void> acceptDelivery(String deliveryId) async {
    final index = deliveries.indexWhere((d) => d.id == deliveryId);
    if (index == -1) return;

    final delivery = deliveries[index];
    if (!delivery.canAccept) {
      _snack('Error', 'This delivery cannot be accepted', Colors.red);
      return;
    }

    if (activeDelivery.value != null) {
      _snack('Active Delivery', 'Please complete your current delivery first', Colors.orange);
      return;
    }

    final result = await acceptDeliveryUseCase(AcceptDeliveryParams(deliveryId: deliveryId));
    result.fold(
      (failure) => _snack('Error', 'Failed to accept: ${failure.message}', Colors.red),
      (updated) {
        deliveries[index] = updated;
        activeDelivery.value = updated;

        locationController.startTracking(deliveryId: deliveryId);

        _snack('Delivery Accepted', 'Navigate to the pickup location', Colors.green);
      },
    );
  }

  Future<void> markAsPickedUp(String deliveryId) async {
    final index = deliveries.indexWhere((d) => d.id == deliveryId);
    if (index == -1) return;

    final delivery = deliveries[index];
    if (!delivery.canPickup) {
      _snack('Error', 'Cannot mark as picked up', Colors.red);
      return;
    }

    final updated = delivery.copyWith(status: DeliveryStatus.pickedUp, pickedUpAt: DateTime.now());
    deliveries[index] = updated;
    activeDelivery.value = updated;

    await repository.persistLocalChange(updated);
    pendingSyncCount.value++;

    _snack('Order Picked Up', 'Navigate to the customer location', Colors.blue);
  }

  Future<void> markAsInTransit(String deliveryId) async {
    final index = deliveries.indexWhere((d) => d.id == deliveryId);
    if (index == -1) return;

    final updated = deliveries[index].copyWith(status: DeliveryStatus.inTransit);
    deliveries[index] = updated;
    activeDelivery.value = updated;

    await repository.persistLocalChange(updated);
    pendingSyncCount.value++;
  }

  Future<void> completeDelivery({required String deliveryId, String? proofImage, String? notes}) async {
    final index = deliveries.indexWhere((d) => d.id == deliveryId);
    if (index == -1) return;

    final delivery = deliveries[index];
    if (!delivery.canComplete) {
      _snack('Error', 'Cannot complete this delivery', Colors.red);
      return;
    }

    final result = await completeDeliveryUseCase(
      CompleteDeliveryParams(deliveryId: deliveryId, proofImage: proofImage, notes: notes),
    );
    result.fold(
      (failure) => _snack('Error', 'Failed to complete: ${failure.message}', Colors.red),
      (updated) {
        deliveries[index] = updated;
        if (activeDelivery.value?.id == deliveryId) activeDelivery.value = null;

        locationController.stopTracking();

        _snack('Delivery Completed', 'You earned ${updated.totalEarnings.toStringAsFixed(2)}', Colors.green,
            duration: const Duration(seconds: 5));
      },
    );
  }

  Future<String?> captureProofOfDelivery() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70, maxWidth: 1024);
      return image?.path;
    } catch (e) {
      AppLogger.error('Failed to capture proof of delivery', error: e);
      _snack('Error', 'Failed to capture image', Colors.red);
      return null;
    }
  }

  Future<void> syncOfflineData() async {
    if (isSyncing.value) return;
    isSyncing.value = true;

    final result = await syncOfflineDeliveriesUseCase(SyncOfflineDeliveriesParams());
    result.fold(
      (failure) => AppLogger.error('Failed to sync offline data', data: {'error': failure.message}),
      (syncedCount) {
        if (syncedCount > 0) {
          AppLogger.info('Synced $syncedCount offline deliveries');
          loadDeliveries(silent: true);
        }
        pendingSyncCount.value = 0;
      },
    );

    isSyncing.value = false;
  }

  Delivery? getDeliveryById(String deliveryId) {
    for (final d in deliveries) {
      if (d.id == deliveryId) return d;
    }
    return null;
  }

  void _snack(String title, String message, Color color, {Duration? duration}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}
