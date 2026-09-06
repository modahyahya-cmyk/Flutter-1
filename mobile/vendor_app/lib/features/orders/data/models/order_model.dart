import '../../../../core/utils/parsers.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.uuid,
    required super.orderNumber,
    required super.customerId,
    required super.vendorId,
    super.branchId,
    super.driverId,
    required super.orderType,
    required super.status,
    required super.paymentStatus,
    required super.subtotal,
    required super.taxAmount,
    required super.deliveryFee,
    required super.discountAmount,
    required super.tipAmount,
    required super.totalAmount,
    required super.commissionAmount,
    required super.vendorEarnings,
    super.deliveryAddress,
    super.deliveryLatitude,
    super.deliveryLongitude,
    super.deliveryPhone,
    super.deliveryNotes,
    super.deliveryDistanceKm,
    super.confirmedAt,
    super.preparingAt,
    super.readyAt,
    super.pickedUpAt,
    super.deliveredAt,
    super.cancelledAt,
    super.scheduledFor,
    super.customerNotes,
    super.vendorNotes,
    super.cancellationReason,
    super.paymentMethod,
    super.paymentTransactionId,
    super.customerRating,
    super.customerReview,
    required super.items,
    required super.customer,
    required super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final customerJson = json['customer'] as Map<String, dynamic>? ?? const {};
    final itemsJson = (json['items'] as List? ?? []).cast<Map<String, dynamic>>();

    return OrderModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String? ?? '',
      orderNumber: json['order_number'] as String,
      customerId: json['customer_id'] as int,
      vendorId: json['vendor_id'] as int,
      branchId: json['branch_id'] as int?,
      driverId: json['driver_id'] as int?,
      orderType: OrderTypeX.fromWire(json['order_type'] as String?),
      status: OrderStatusX.fromWire(json['status'] as String?),
      paymentStatus: PaymentStatusX.fromWire(json['payment_status'] as String?),
      subtotal: Parsers.doubleOf(json['subtotal']),
      taxAmount: Parsers.doubleOf(json['tax_amount']),
      deliveryFee: Parsers.doubleOf(json['delivery_fee']),
      discountAmount: Parsers.doubleOf(json['discount_amount']),
      tipAmount: Parsers.doubleOf(json['tip_amount']),
      totalAmount: Parsers.doubleOf(json['total_amount']),
      commissionAmount: Parsers.doubleOf(json['commission_amount']),
      vendorEarnings: Parsers.doubleOf(json['vendor_earnings']),
      deliveryAddress: json['delivery_address'] as String?,
      deliveryLatitude: Parsers.doubleOrNull(json['delivery_latitude']),
      deliveryLongitude: Parsers.doubleOrNull(json['delivery_longitude']),
      deliveryPhone: json['delivery_phone'] as String?,
      deliveryNotes: json['delivery_notes'] as String?,
      deliveryDistanceKm: Parsers.doubleOrNull(json['delivery_distance_km']),
      confirmedAt: Parsers.dateTimeOrNull(json['confirmed_at']),
      preparingAt: Parsers.dateTimeOrNull(json['preparing_at']),
      readyAt: Parsers.dateTimeOrNull(json['ready_at']),
      pickedUpAt: Parsers.dateTimeOrNull(json['picked_up_at']),
      deliveredAt: Parsers.dateTimeOrNull(json['delivered_at']),
      cancelledAt: Parsers.dateTimeOrNull(json['cancelled_at']),
      scheduledFor: Parsers.dateTimeOrNull(json['scheduled_for']),
      customerNotes: json['customer_notes'] as String?,
      vendorNotes: json['vendor_notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      paymentMethod: json['payment_method'] as String?,
      paymentTransactionId: json['payment_transaction_id'] as String?,
      customerRating: json['customer_rating'] as int?,
      customerReview: json['customer_review'] as String?,
      items: itemsJson.map(OrderItemModel.fromJson).toList(),
      customer: OrderCustomer(
        id: customerJson['id'] as int? ?? 0,
        firstName: customerJson['first_name'] as String?,
        lastName: customerJson['last_name'] as String?,
        phone: customerJson['phone'] as String?,
        email: customerJson['email'] as String?,
      ),
      createdAt: Parsers.dateTimeOrNull(json['created_at']) ?? DateTime.now(),
    );
  }
}

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.unitPrice,
    required super.totalAmount,
    super.variantId,
    super.variantName,
    super.image,
    super.options,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: Parsers.doubleOf(json['unit_price']),
      totalAmount: Parsers.doubleOf(json['total_amount']),
      variantId: json['variant_id'] as int?,
      variantName: json['variant_name'] as String?,
      image: json['image'] as String?,
      options: json['options'] as Map<String, dynamic>?,
    );
  }
}
