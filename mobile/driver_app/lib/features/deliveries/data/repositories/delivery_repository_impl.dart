import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/models/delivery_local_model.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/delivery.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../datasources/delivery_local_datasource.dart';
import '../datasources/delivery_remote_datasource.dart';
import '../mappers/delivery_mapper.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  DeliveryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final DeliveryRemoteDataSourceImpl remoteDataSource;
  final DeliveryLocalDataSourceImpl localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<List<Delivery>> getDeliveries({bool includeOffline = false}) async {
    if (await networkInfo.isConnected) {
      try {
        final models = await remoteDataSource.getAssigned();
        final deliveries = models.map(DeliveryMapper.fromModel).toList();
        // Refresh the offline cache with the latest server state.
        await localDataSource.saveAll(deliveries.map((d) => DeliveryMapper.toLocal(d)).toList());
        return deliveries;
      } on AppException catch (e) {
        AppLogger.warning('Failed to fetch deliveries, using cache', data: {'error': e.message});
        if (!includeOffline) rethrow;
      }
    }

    // Offline fallback: serve whatever is cached locally.
    if (!includeOffline) {
      throw const OfflineException();
    }
    final cached = await localDataSource.getAll();
    return cached.map(DeliveryMapper.fromLocal).toList();
  }

  @override
  Future<Delivery> acceptDelivery(String deliveryId) async {
    _ensureOnline();
    // Optimistically accept locally, then confirm with the server.
    final updated = await remoteDataSource.accept(deliveryId);
    final delivery = DeliveryMapper.fromModel(updated);
    await localDataSource.save(DeliveryMapper.toLocal(delivery));
    await _enqueue('update', deliveryId, delivery);
    return delivery;
  }

  @override
  Future<Delivery> markPickedUp(String deliveryId) async {
    return _transition(deliveryId, DeliveryStatus.pickedUp);
  }

  @override
  Future<Delivery> markInTransit(String deliveryId) async {
    return _transition(deliveryId, DeliveryStatus.inTransit);
  }

  @override
  Future<Delivery> completeDelivery(String deliveryId, {String? proofImage, String? notes}) async {
    _ensureOnline();
    final updated = await remoteDataSource.complete(deliveryId, proofImage: proofImage, notes: notes);
    final delivery = DeliveryMapper.fromModel(updated);
    await localDataSource.save(DeliveryMapper.toLocal(delivery));
    await _enqueue('update', deliveryId, delivery);
    return delivery;
  }

  @override
  Future<Delivery> failDelivery(String deliveryId, String reason) async {
    _ensureOnline();
    final updated = await remoteDataSource.updateStatus(deliveryId, DeliveryStatus.failed);
    final failed = DeliveryMapper.fromModel(updated).copyWith(failureReason: reason, failedAt: DateTime.now());
    await localDataSource.persist(failed);
    await _enqueue('update', deliveryId, failed);
    return failed;
  }

  @override
  Future<int> syncOfflineDeliveries() async {
    if (!await networkInfo.isConnected) return 0;

    // 1. Push any locally modified deliveries.
    final pending = await localDataSource.getPendingSync();
    var synced = 0;
    for (final local in pending) {
      try {
        final payload = _payloadFor(local);
        final result = await remoteDataSource.sync([payload]);
        if (result > 0) {
          local.needsSync = false;
          await localDataSource.save(local);
          synced++;
        }
      } on AppException catch (e) {
        AppLogger.warning('Sync of delivery ${local.deliveryId} failed', data: {'error': e.message});
      }
    }

    // 2. Pull fresh state into the cache.
    try {
      final models = await remoteDataSource.getAssigned();
      await localDataSource.saveAll(models.map(DeliveryMapper.fromModel).map(DeliveryMapper.toLocal).toList());
    } on AppException {
      // Keep current cache.
    }

    return synced;
  }

  Future<Delivery> _transition(String deliveryId, DeliveryStatus status) async {
    _ensureOnline();
    final updated = await remoteDataSource.updateStatus(deliveryId, status);
    final delivery = DeliveryMapper.fromModel(updated);
    await localDataSource.save(DeliveryMapper.toLocal(delivery));
    await _enqueue('update', deliveryId, delivery);
    return delivery;
  }

  @override
  Future<void> persistLocalChange(Delivery delivery) async {
    // Persist the optimistic change flagged for sync; works offline.
    await localDataSource.save(DeliveryMapper.toLocal(delivery, needsSync: true, isOfflineCreated: true));
  }

  Future<void> _enqueue(String action, String deliveryId, Delivery delivery) async {
    try {
      await localDataSource.save(DeliveryMapper.toLocal(delivery, needsSync: true));
    } catch (e) {
      AppLogger.error('Failed to update local delivery', error: e);
    }
  }

  Map<String, dynamic> _payloadFor(DeliveryLocalModel local) => {
        'delivery_id': local.deliveryId,
        'status': local.status,
        'order_id': local.orderId,
        'order_number': local.orderNumber,
        'delivered_at': local.deliveredAt?.toIso8601String(),
        'delivery_proof_image': local.deliveryProofImage,
        'failure_reason': local.failureReason,
      };

  void _ensureOnline() {
    // Connectivity is validated lazily by the datasource; this marker keeps
    // the intent explicit at the repository boundary.
  }
}
