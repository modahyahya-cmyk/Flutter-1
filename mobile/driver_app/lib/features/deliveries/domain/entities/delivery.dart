enum DeliveryStatus {
  assigned,
  accepted,
  pickedUp,
  inTransit,
  delivered,
  failed;

  String get wire => switch (this) {
        DeliveryStatus.assigned => 'assigned',
        DeliveryStatus.accepted => 'accepted',
        DeliveryStatus.pickedUp => 'picked_up',
        DeliveryStatus.inTransit => 'in_transit',
        DeliveryStatus.delivered => 'delivered',
        DeliveryStatus.failed => 'failed',
      };

  /// Human readable label used by the UI (e.g. delivery detail page).
  String get label => switch (this) {
        DeliveryStatus.assigned => 'Assigned',
        DeliveryStatus.accepted => 'Accepted',
        DeliveryStatus.pickedUp => 'Picked Up',
        DeliveryStatus.inTransit => 'In Transit',
        DeliveryStatus.delivered => 'Delivered',
        DeliveryStatus.failed => 'Failed',
      };

  static DeliveryStatus fromWire(String? value) {
    switch (value) {
      case 'accepted': return DeliveryStatus.accepted;
      case 'picked_up': return DeliveryStatus.pickedUp;
      case 'in_transit': return DeliveryStatus.inTransit;
      case 'delivered': return DeliveryStatus.delivered;
      case 'failed': return DeliveryStatus.failed;
      default: return DeliveryStatus.assigned;
    }
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  const LatLng({required this.latitude, required this.longitude});
}

/// A single line item within the order attached to a delivery, used only for
/// display (not persisted offline).
class DeliveryOrderItem {
  final String productName;
  final int quantity;
  final double price;

  const DeliveryOrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });
}

class Delivery {
  final String id;
  final String orderId;
  final String orderNumber;
  final DeliveryStatus status;

  final String vendorName;
  final String? vendorPhone;

  final String customerName;
  final String? customerPhone;

  final LatLng pickupLocation;
  final String pickupAddress;

  final LatLng dropoffLocation;
  final String dropoffAddress;

  final double distanceKm;

  final double deliveryFee;
  final double driverEarnings;
  final double platformCommission;
  final double tipAmount;

  /// Total amount of the underlying order (not the driver's earnings).
  final double orderTotal;

  /// Order line items, for display only — not persisted to the offline cache.
  final List<DeliveryOrderItem> items;

  final DateTime? assignedAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? arrivedAt;
  final DateTime? deliveredAt;
  final DateTime? failedAt;

  final String? deliveryNotes;
  final String? failureReason;
  final String? deliveryProofImage;

  final bool needsSync;
  final bool isOfflineCreated;

  const Delivery({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.status,
    this.vendorName = '',
    this.vendorPhone,
    this.customerName = '',
    this.customerPhone,
    required this.pickupLocation,
    this.pickupAddress = '',
    required this.dropoffLocation,
    this.dropoffAddress = '',
    this.distanceKm = 0,
    this.deliveryFee = 0,
    this.driverEarnings = 0,
    this.platformCommission = 0,
    this.tipAmount = 0,
    this.orderTotal = 0,
    this.items = const [],
    this.assignedAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.arrivedAt,
    this.deliveredAt,
    this.failedAt,
    this.deliveryNotes,
    this.failureReason,
    this.deliveryProofImage,
    this.needsSync = false,
    this.isOfflineCreated = false,
  });

  /// Total the driver earns for this delivery (base earnings + tip).
  double get totalEarnings => driverEarnings + tipAmount;

  bool get canAccept => status == DeliveryStatus.assigned;
  bool get canPickup => status == DeliveryStatus.accepted;
  bool get canComplete => status == DeliveryStatus.inTransit;

  Delivery copyWith({
    String? id,
    String? orderId,
    String? orderNumber,
    DeliveryStatus? status,
    String? vendorName,
    String? vendorPhone,
    String? customerName,
    String? customerPhone,
    LatLng? pickupLocation,
    String? pickupAddress,
    LatLng? dropoffLocation,
    String? dropoffAddress,
    double? distanceKm,
    double? deliveryFee,
    double? driverEarnings,
    double? platformCommission,
    double? tipAmount,
    double? orderTotal,
    List<DeliveryOrderItem>? items,
    DateTime? assignedAt,
    DateTime? acceptedAt,
    DateTime? pickedUpAt,
    DateTime? arrivedAt,
    DateTime? deliveredAt,
    DateTime? failedAt,
    String? deliveryNotes,
    String? failureReason,
    String? deliveryProofImage,
    bool? needsSync,
    bool? isOfflineCreated,
  }) {
    return Delivery(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      vendorName: vendorName ?? this.vendorName,
      vendorPhone: vendorPhone ?? this.vendorPhone,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      distanceKm: distanceKm ?? this.distanceKm,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      driverEarnings: driverEarnings ?? this.driverEarnings,
      platformCommission: platformCommission ?? this.platformCommission,
      tipAmount: tipAmount ?? this.tipAmount,
      orderTotal: orderTotal ?? this.orderTotal,
      items: items ?? this.items,
      assignedAt: assignedAt ?? this.assignedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      failedAt: failedAt ?? this.failedAt,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      failureReason: failureReason ?? this.failureReason,
      deliveryProofImage: deliveryProofImage ?? this.deliveryProofImage,
      needsSync: needsSync ?? this.needsSync,
      isOfflineCreated: isOfflineCreated ?? this.isOfflineCreated,
    );
  }
}
