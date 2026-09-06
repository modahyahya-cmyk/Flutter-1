import 'package:isar/isar.dart';

part 'location_log_model.g.dart';

@collection
class LocationLogModel {
  Id id = Isar.autoIncrement;

  late double latitude;
  late double longitude;
  late double accuracy;
  late double? altitude;
  late double? speed;
  late double? heading;

  @Index()
  late DateTime timestamp;

  @Index()
  String? deliveryId;

  @Index()
  late bool isUploaded;

  late String? batteryLevel;
  late bool? isCharging;

  LocationLogModel({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    required this.timestamp,
    this.deliveryId,
    this.isUploaded = false,
    this.batteryLevel,
    this.isCharging,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      'delivery_id': deliveryId,
      'battery_level': batteryLevel,
      'is_charging': isCharging,
    };
  }
}
