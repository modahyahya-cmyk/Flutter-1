import '../../domain/entities/delivery.dart';

class DeliveryModel {
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
  final double orderTotal;
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

  const DeliveryModel({
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
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    LatLng point(dynamic value) {
      if (value is Map) {
        return LatLng(
          latitude: (value['latitude'] ?? value['lat'] ?? 0).toDouble(),
          longitude: (value['longitude'] ?? value['lng'] ?? 0).toDouble(),
        );
      }
      return const LatLng(latitude: 0, longitude: 0);
    }

    DateTime? date(dynamic value) =>
        value == null ? null : DateTime.tryParse(value.toString());

    final vendor = json['vendor'] is Map ? json['vendor'] as Map : const {};
    final customer = json['customer'] is Map ? json['customer'] as Map : const {};
    final order = json['order'] is Map ? json['order'] as Map : const {};

    final rawItems = (order['items'] ?? json['items']);
    final items = <DeliveryOrderItem>[];
    if (rawItems is List) {
      for (final raw in rawItems) {
        if (raw is Map) {
          items.add(DeliveryOrderItem(
            productName: (raw['product_name'] ?? raw['name'] ?? '').toString(),
            quantity: int.tryParse((raw['quantity'] ?? 1).toString()) ?? 1,
            price: (raw['price'] ?? 0).toDouble(),
          ));
        }
      }
    }

    return DeliveryModel(
      id: (json['delivery_id'] ?? json['id'] ?? '').toString(),
      orderId: (json['order_id'] ?? '').toString(),
      orderNumber: (json['order_number'] ?? '').toString(),
      status: DeliveryStatus.fromWire(json['status']?.toString()),
      vendorName: (json['vendor_name'] ?? vendor['business_name'] ?? vendor['name'] ?? '').toString(),
      vendorPhone: (json['vendor_phone'] ?? vendor['phone'])?.toString(),
      customerName: (json['customer_name'] ?? customer['name'] ?? '').toString(),
      customerPhone: (json['customer_phone'] ?? customer['phone'])?.toString(),
      pickupLocation: point(json['pickup_location'] ?? json['pickup']),
      pickupAddress: (json['pickup_address'] ?? '').toString(),
      dropoffLocation: point(json['dropoff_location'] ?? json['dropoff']),
      dropoffAddress: (json['dropoff_address'] ?? '').toString(),
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      driverEarnings: (json['driver_earnings'] ?? 0).toDouble(),
      platformCommission: (json['platform_commission'] ?? 0).toDouble(),
      tipAmount: (json['tip_amount'] ?? 0).toDouble(),
      orderTotal: (json['order_total'] ?? order['total_amount'] ?? json['total_amount'] ?? json['amount'] ?? 0).toDouble(),
      items: items,
      assignedAt: date(json['assigned_at']),
      acceptedAt: date(json['accepted_at']),
      pickedUpAt: date(json['picked_up_at']),
      arrivedAt: date(json['arrived_at']),
      deliveredAt: date(json['delivered_at']),
      failedAt: date(json['failed_at']),
      deliveryNotes: json['delivery_notes']?.toString(),
      failureReason: json['failure_reason']?.toString(),
      deliveryProofImage: json['delivery_proof_image']?.toString(),
    );
  }
}
