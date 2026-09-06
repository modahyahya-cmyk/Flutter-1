import '../../../../core/storage/isar_service.dart';
import '../../../../core/storage/models/delivery_local_model.dart';
import '../../domain/entities/delivery.dart';
import '../mappers/delivery_mapper.dart';

class DeliveryLocalDataSourceImpl {
  DeliveryLocalDataSourceImpl({required this.isarService});

  final IsarService isarService;

  Future<void> save(DeliveryLocalModel delivery) => isarService.saveDelivery(delivery);

  Future<void> saveAll(List<DeliveryLocalModel> deliveries) => isarService.saveDeliveries(deliveries);

  Future<DeliveryLocalModel?> getById(String deliveryId) => isarService.getDeliveryById(deliveryId);

  Future<List<DeliveryLocalModel>> getAll() => isarService.getAllDeliveries();

  Future<List<DeliveryLocalModel>> getByStatus(String status) => isarService.getDeliveriesByStatus(status);

  Future<List<DeliveryLocalModel>> getPendingSync() => isarService.getPendingSyncDeliveries();

  Future<void> delete(String deliveryId) => isarService.deleteDelivery(deliveryId);

  /// Writes the entity graph to the local database (used for offline-first).
  Future<void> persist(Delivery delivery) async {
    final local = DeliveryMapper.toLocal(delivery);
    await isarService.saveDelivery(local);
  }
}
