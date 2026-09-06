import 'package:isar/isar.dart';

import 'models/delivery_local_model.dart';
import 'models/earnings_local_model.dart';
import 'models/location_log_model.dart';
import 'models/sync_queue_model.dart';
import '../utils/logger.dart';

class IsarService {
  IsarService({required this.isar});

  final Isar isar;

  // =========================================================================
  // DELIVERY OPERATIONS
  // =========================================================================

  Future<void> saveDelivery(DeliveryLocalModel delivery) async {
    try {
      await isar.writeTxn(() async {
        await isar.deliveryLocalModels.put(delivery);
      });
      AppLogger.debug('Delivery saved to local DB', data: {'delivery_id': delivery.deliveryId});
    } catch (e) {
      AppLogger.error('Failed to save delivery', error: e);
      rethrow;
    }
  }

  Future<void> saveDeliveries(List<DeliveryLocalModel> deliveries) async {
    try {
      await isar.writeTxn(() async {
        await isar.deliveryLocalModels.putAll(deliveries);
      });
      AppLogger.debug('Saved ${deliveries.length} deliveries to local DB');
    } catch (e) {
      AppLogger.error('Failed to save deliveries', error: e);
      rethrow;
    }
  }

  Future<DeliveryLocalModel?> getDeliveryById(String deliveryId) async {
    try {
      return await isar.deliveryLocalModels.filter().deliveryIdEqualTo(deliveryId).findFirst();
    } catch (e) {
      AppLogger.error('Failed to get delivery', error: e);
      return null;
    }
  }

  Future<List<DeliveryLocalModel>> getAllDeliveries() async {
    try {
      return await isar.deliveryLocalModels.where().findAll();
    } catch (e) {
      AppLogger.error('Failed to get all deliveries', error: e);
      return [];
    }
  }

  Future<List<DeliveryLocalModel>> getDeliveriesByStatus(String status) async {
    try {
      return await isar.deliveryLocalModels.filter().statusEqualTo(status).findAll();
    } catch (e) {
      AppLogger.error('Failed to get deliveries by status', error: e);
      return [];
    }
  }

  Future<List<DeliveryLocalModel>> getPendingSyncDeliveries() async {
    try {
      return await isar.deliveryLocalModels.filter().needsSyncEqualTo(true).findAll();
    } catch (e) {
      AppLogger.error('Failed to get pending sync deliveries', error: e);
      return [];
    }
  }

  Future<void> updateDelivery(DeliveryLocalModel delivery) => saveDelivery(delivery);

  Future<void> deleteDelivery(String deliveryId) async {
    try {
      await isar.writeTxn(() async {
        final delivery = await isar.deliveryLocalModels.filter().deliveryIdEqualTo(deliveryId).findFirst();
        if (delivery != null) {
          await isar.deliveryLocalModels.delete(delivery.id);
        }
      });
      AppLogger.debug('Delivery deleted from local DB', data: {'delivery_id': deliveryId});
    } catch (e) {
      AppLogger.error('Failed to delete delivery', error: e);
      rethrow;
    }
  }

  // =========================================================================
  // LOCATION LOG OPERATIONS
  // =========================================================================

  Future<void> saveLocationLog(LocationLogModel location) async {
    try {
      await isar.writeTxn(() async {
        await isar.locationLogModels.put(location);
      });
    } catch (e) {
      AppLogger.error('Failed to save location log', error: e);
      rethrow;
    }
  }

  Future<void> saveLocationLogs(List<LocationLogModel> locations) async {
    try {
      await isar.writeTxn(() async {
        await isar.locationLogModels.putAll(locations);
      });
      AppLogger.debug('Saved ${locations.length} location logs');
    } catch (e) {
      AppLogger.error('Failed to save location logs', error: e);
      rethrow;
    }
  }

  Future<List<LocationLogModel>> getUnuploadedLocations() async {
    try {
      return await isar.locationLogModels.filter().isUploadedEqualTo(false).sortByTimestamp().findAll();
    } catch (e) {
      AppLogger.error('Failed to get unuploaded locations', error: e);
      return [];
    }
  }

  Future<List<LocationLogModel>> getLocationsByDelivery(String deliveryId) async {
    try {
      return await isar.locationLogModels.filter().deliveryIdEqualTo(deliveryId).sortByTimestamp().findAll();
    } catch (e) {
      AppLogger.error('Failed to get locations by delivery', error: e);
      return [];
    }
  }

  Future<void> markLocationsAsUploaded(List<int> ids) async {
    try {
      await isar.writeTxn(() async {
        for (final id in ids) {
          final location = await isar.locationLogModels.get(id);
          if (location != null) {
            location.isUploaded = true;
            await isar.locationLogModels.put(location);
          }
        }
      });
      AppLogger.debug('Marked ${ids.length} locations as uploaded');
    } catch (e) {
      AppLogger.error('Failed to mark locations as uploaded', error: e);
      rethrow;
    }
  }

  Future<void> deleteOldLocationLogs(DateTime before) async {
    try {
      await isar.writeTxn(() async {
        final oldLogs = await isar.locationLogModels.filter().timestampLessThan(before).findAll();
        for (final log in oldLogs) {
          await isar.locationLogModels.delete(log.id);
        }
      });
      AppLogger.debug('Deleted old location logs before $before');
    } catch (e) {
      AppLogger.error('Failed to delete old location logs', error: e);
    }
  }

  // =========================================================================
  // EARNINGS OPERATIONS
  // =========================================================================

  Future<void> saveEarning(EarningsLocalModel earning) async {
    try {
      await isar.writeTxn(() async {
        await isar.earningsLocalModels.put(earning);
      });
      AppLogger.debug('Earning saved to local DB', data: {'earning_id': earning.earningId});
    } catch (e) {
      AppLogger.error('Failed to save earning', error: e);
      rethrow;
    }
  }

  Future<List<EarningsLocalModel>> getAllEarnings() async {
    try {
      return await isar.earningsLocalModels.where().sortByDateDesc().findAll();
    } catch (e) {
      AppLogger.error('Failed to get all earnings', error: e);
      return [];
    }
  }

  Future<List<EarningsLocalModel>> getEarningsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      return await isar.earningsLocalModels.filter().dateBetween(startDate, endDate).sortByDateDesc().findAll();
    } catch (e) {
      AppLogger.error('Failed to get earnings by date range', error: e);
      return [];
    }
  }

  Future<double> getTotalEarnings() async {
    try {
      final earnings = await getAllEarnings();
      return earnings.fold<double>(0.0, (sum, earning) => sum + earning.amount);
    } catch (e) {
      AppLogger.error('Failed to calculate total earnings', error: e);
      return 0.0;
    }
  }

  Future<double> getTotalEarningsForPeriod(DateTime startDate, DateTime endDate) async {
    try {
      final earnings = await getEarningsByDateRange(startDate, endDate);
      return earnings.fold<double>(0.0, (sum, earning) => sum + earning.amount);
    } catch (e) {
      AppLogger.error('Failed to calculate period earnings', error: e);
      return 0.0;
    }
  }

  // =========================================================================
  // SYNC QUEUE OPERATIONS
  // =========================================================================

  Future<void> addToSyncQueue(SyncQueueModel item) async {
    try {
      await isar.writeTxn(() async {
        await isar.syncQueueModels.put(item);
      });
      AppLogger.debug('Added item to sync queue', data: {'action': item.action, 'entity_type': item.entityType});
    } catch (e) {
      AppLogger.error('Failed to add to sync queue', error: e);
      rethrow;
    }
  }

  Future<List<SyncQueueModel>> getPendingSyncItems() async {
    try {
      return await isar.syncQueueModels.filter().isSyncedEqualTo(false).sortByCreatedAt().findAll();
    } catch (e) {
      AppLogger.error('Failed to get pending sync items', error: e);
      return [];
    }
  }

  Future<void> markAsSynced(int id) async {
    try {
      await isar.writeTxn(() async {
        final item = await isar.syncQueueModels.get(id);
        if (item != null) {
          item.isSynced = true;
          item.syncedAt = DateTime.now();
          await isar.syncQueueModels.put(item);
        }
      });
    } catch (e) {
      AppLogger.error('Failed to mark as synced', error: e);
      rethrow;
    }
  }

  Future<void> deleteSyncedItems() async {
    try {
      await isar.writeTxn(() async {
        final syncedItems = await isar.syncQueueModels.filter().isSyncedEqualTo(true).findAll();
        for (final item in syncedItems) {
          await isar.syncQueueModels.delete(item.id);
        }
      });
      AppLogger.debug('Deleted synced items from queue');
    } catch (e) {
      AppLogger.error('Failed to delete synced items', error: e);
    }
  }

  Future<void> incrementRetryCount(int id) async {
    try {
      await isar.writeTxn(() async {
        final item = await isar.syncQueueModels.get(id);
        if (item != null) {
          item.retryCount++;
          item.lastAttemptAt = DateTime.now();
          await isar.syncQueueModels.put(item);
        }
      });
    } catch (e) {
      AppLogger.error('Failed to increment retry count', error: e);
      rethrow;
    }
  }

  // =========================================================================
  // DATABASE MAINTENANCE
  // =========================================================================

  Future<void> clearAllData() async {
    try {
      await isar.writeTxn(() async {
        await isar.deliveryLocalModels.clear();
        await isar.locationLogModels.clear();
        await isar.earningsLocalModels.clear();
        await isar.syncQueueModels.clear();
      });
      AppLogger.info('Cleared all local database data');
    } catch (e) {
      AppLogger.error('Failed to clear database', error: e);
      rethrow;
    }
  }

  Future<Map<String, int>> getDatabaseStats() async {
    try {
      final deliveries = await isar.deliveryLocalModels.count();
      final locations = await isar.locationLogModels.count();
      final earnings = await isar.earningsLocalModels.count();
      final syncQueue = await isar.syncQueueModels.count();

      return {
        'deliveries': deliveries,
        'locations': locations,
        'earnings': earnings,
        'sync_queue': syncQueue,
      };
    } catch (e) {
      AppLogger.error('Failed to get database stats', error: e);
      return {};
    }
  }
}
