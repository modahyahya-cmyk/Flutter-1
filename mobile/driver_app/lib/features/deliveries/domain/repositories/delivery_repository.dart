import '../entities/delivery.dart';

abstract class DeliveryRepository {
  Future<List<Delivery>> getDeliveries({bool includeOffline = false});
  Future<Delivery> acceptDelivery(String deliveryId);
  Future<Delivery> markPickedUp(String deliveryId);
  Future<Delivery> markInTransit(String deliveryId);
  Future<Delivery> completeDelivery(String deliveryId, {String? proofImage, String? notes});
  Future<Delivery> failDelivery(String deliveryId, String reason);
  Future<int> syncOfflineDeliveries();

  /// Persists an optimistic local status change that will be pushed to the
  /// server by the next sync (offline-first behaviour).
  Future<void> persistLocalChange(Delivery delivery);
}
