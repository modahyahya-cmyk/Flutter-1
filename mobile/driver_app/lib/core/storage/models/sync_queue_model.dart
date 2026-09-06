import 'package:isar/isar.dart';

part 'sync_queue_model.g.dart';

@collection
class SyncQueueModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String action; // create, update, delete

  late String entityType; // delivery, location, earning

  late String entityId;

  late String payload; // JSON string

  @Index()
  late bool isSynced;

  late int retryCount;

  DateTime? createdAt;
  DateTime? syncedAt;
  DateTime? lastAttemptAt;

  SyncQueueModel({
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.payload,
    this.isSynced = false,
    this.retryCount = 0,
    DateTime? createdAt,
    this.syncedAt,
    this.lastAttemptAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
