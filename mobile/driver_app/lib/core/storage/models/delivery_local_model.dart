import 'package:isar/isar.dart';

part 'delivery_local_model.g.dart';

@collection
class DeliveryLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String deliveryId;

  late String orderId;
  late String orderNumber;
  late String vendorName;
  String? vendorPhone;
  late String customerName;
  late String? customerPhone;

  late String status; // assigned, accepted, picked_up, in_transit, delivered, failed

  // Pickup Location
  late double pickupLatitude;
  late double pickupLongitude;
  late String pickupAddress;

  // Dropoff Location
  late double dropoffLatitude;
  late double dropoffLongitude;
  late String dropoffAddress;

  late double distanceKm;

  // Earnings
  late double deliveryFee;
  late double driverEarnings;
  late double platformCommission;
  late double tipAmount;

  // Timestamps
  late DateTime assignedAt;
  DateTime? acceptedAt;
  DateTime? pickedUpAt;
  DateTime? arrivedAt;
  DateTime? deliveredAt;
  DateTime? failedAt;

  // Additional Info
  String? deliveryNotes;
  String? deliveryProofImage;
  String? failureReason;

  // Local State
  late bool needsSync;
  late bool isOfflineCreated;
  DateTime? localUpdatedAt;

  DeliveryLocalModel({
    required this.deliveryId,
    required this.orderId,
    required this.orderNumber,
    required this.vendorName,
    this.vendorPhone,
    required this.customerName,
    this.customerPhone,
    required this.status,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.dropoffAddress,
    required this.distanceKm,
    required this.deliveryFee,
    required this.driverEarnings,
    required this.platformCommission,
    required this.tipAmount,
    required this.assignedAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.arrivedAt,
    this.deliveredAt,
    this.failedAt,
    this.deliveryNotes,
    this.deliveryProofImage,
    this.failureReason,
    this.needsSync = false,
    this.isOfflineCreated = false,
    DateTime? localUpdatedAt,
  }) : localUpdatedAt = localUpdatedAt ?? DateTime.now();

  DeliveryLocalModel copyWith({
    String? status,
    DateTime? acceptedAt,
    DateTime? pickedUpAt,
    DateTime? arrivedAt,
    DateTime? deliveredAt,
    DateTime? failedAt,
    String? deliveryProofImage,
    String? failureReason,
    bool? needsSync,
    bool clearAcceptedAt = false,
    bool clearPickedUpAt = false,
    bool clearArrivedAt = false,
    bool clearDeliveredAt = false,
    bool clearFailedAt = false,
    bool clearDeliveryProofImage = false,
    bool clearFailureReason = false,
  }) {
    return DeliveryLocalModel(
      deliveryId: deliveryId,
      orderId: orderId,
      orderNumber: orderNumber,
      vendorName: vendorName,
      vendorPhone: vendorPhone,
      customerName: customerName,
      customerPhone: customerPhone,
      status: status ?? this.status,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      pickupAddress: pickupAddress,
      dropoffLatitude: dropoffLatitude,
      dropoffLongitude: dropoffLongitude,
      dropoffAddress: dropoffAddress,
      distanceKm: distanceKm,
      deliveryFee: deliveryFee,
      driverEarnings: driverEarnings,
      platformCommission: platformCommission,
      tipAmount: tipAmount,
      assignedAt: assignedAt,
      acceptedAt: clearAcceptedAt ? null : (acceptedAt ?? this.acceptedAt),
      pickedUpAt: clearPickedUpAt ? null : (pickedUpAt ?? this.pickedUpAt),
      arrivedAt: clearArrivedAt ? null : (arrivedAt ?? this.arrivedAt),
      deliveredAt: clearDeliveredAt ? null : (deliveredAt ?? this.deliveredAt),
      failedAt: clearFailedAt ? null : (failedAt ?? this.failedAt),
      deliveryNotes: deliveryNotes,
      deliveryProofImage: clearDeliveryProofImage
          ? null
          : (deliveryProofImage ?? this.deliveryProofImage),
      failureReason: clearFailureReason
          ? null
          : (failureReason ?? this.failureReason),
      needsSync: needsSync ?? this.needsSync,
      isOfflineCreated: isOfflineCreated,
      localUpdatedAt: DateTime.now(),
    );
  }
}
