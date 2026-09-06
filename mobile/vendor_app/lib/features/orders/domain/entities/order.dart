import 'package:equatable/equatable.dart';

import 'order_item.dart';

enum OrderType { delivery, pickup, dineIn }

enum OrderStatus { pending, confirmed, preparing, readyForPickup, outForDelivery, delivered, cancelled, refunded }

enum PaymentStatus { pending, processing, completed, failed, refunded }

extension OrderTypeX on OrderType {
  String get wire => switch (this) {
        OrderType.delivery => 'delivery',
        OrderType.pickup => 'pickup',
        OrderType.dineIn => 'dine_in',
      };

  static OrderType fromWire(String? v) => switch (v) {
        'pickup' => OrderType.pickup,
        'dine_in' => OrderType.dineIn,
        _ => OrderType.delivery,
      };
}

extension OrderStatusX on OrderStatus {
  String get wire => switch (this) {
        OrderStatus.pending => 'pending',
        OrderStatus.confirmed => 'confirmed',
        OrderStatus.preparing => 'preparing',
        OrderStatus.readyForPickup => 'ready_for_pickup',
        OrderStatus.outForDelivery => 'out_for_delivery',
        OrderStatus.delivered => 'delivered',
        OrderStatus.cancelled => 'cancelled',
        OrderStatus.refunded => 'refunded',
      };

  static OrderStatus fromWire(String? v) => switch (v) {
        'confirmed' => OrderStatus.confirmed,
        'preparing' => OrderStatus.preparing,
        'ready_for_pickup' => OrderStatus.readyForPickup,
        'out_for_delivery' => OrderStatus.outForDelivery,
        'delivered' => OrderStatus.delivered,
        'cancelled' => OrderStatus.cancelled,
        'refunded' => OrderStatus.refunded,
        _ => OrderStatus.pending,
      };

  String get label => switch (this) {
        OrderStatus.pending => 'Pending',
        OrderStatus.confirmed => 'Confirmed',
        OrderStatus.preparing => 'Preparing',
        OrderStatus.readyForPickup => 'Ready for Pickup',
        OrderStatus.outForDelivery => 'Out for Delivery',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
        OrderStatus.refunded => 'Refunded',
      };
}

extension PaymentStatusX on PaymentStatus {
  String get label => switch (this) {
        PaymentStatus.pending => "Pending",
        PaymentStatus.processing => "Processing",
        PaymentStatus.completed => "Completed",
        PaymentStatus.failed => "Failed",
        PaymentStatus.refunded => "Refunded",
      };
  String get wire => switch (this) {
        PaymentStatus.pending => 'pending',
        PaymentStatus.processing => 'processing',
        PaymentStatus.completed => 'completed',
        PaymentStatus.failed => 'failed',
        PaymentStatus.refunded => 'refunded',
      };

  static PaymentStatus fromWire(String? v) => switch (v) {
        'processing' => PaymentStatus.processing,
        'completed' => PaymentStatus.completed,
        'failed' => PaymentStatus.failed,
        'refunded' => PaymentStatus.refunded,
        _ => PaymentStatus.pending,
      };
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.uuid,
    required this.orderNumber,
    required this.customerId,
    required this.vendorId,
    this.branchId,
    this.driverId,
    required this.orderType,
    required this.status,
    required this.paymentStatus,
    required this.subtotal,
    required this.taxAmount,
    required this.deliveryFee,
    required this.discountAmount,
    required this.tipAmount,
    required this.totalAmount,
    required this.commissionAmount,
    required this.vendorEarnings,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.deliveryPhone,
    this.deliveryNotes,
    this.deliveryDistanceKm,
    this.confirmedAt,
    this.preparingAt,
    this.readyAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.cancelledAt,
    this.scheduledFor,
    this.customerNotes,
    this.vendorNotes,
    this.cancellationReason,
    this.paymentMethod,
    this.paymentTransactionId,
    this.customerRating,
    this.customerReview,
    required this.items,
    required this.customer,
    required this.createdAt,
  });

  final int id;
  final String uuid;
  final String orderNumber;
  final int customerId;
  final int vendorId;
  final int? branchId;
  final int? driverId;
  final OrderType orderType;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double subtotal;
  final double taxAmount;
  final double deliveryFee;
  final double discountAmount;
  final double tipAmount;
  final double totalAmount;
  final double commissionAmount;
  final double vendorEarnings;
  final String? deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? deliveryPhone;
  final String? deliveryNotes;
  final double? deliveryDistanceKm;
  final DateTime? confirmedAt;
  final DateTime? preparingAt;
  final DateTime? readyAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime? scheduledFor;
  final String? customerNotes;
  final String? vendorNotes;
  final String? cancellationReason;
  final String? paymentMethod;
  final String? paymentTransactionId;
  final int? customerRating;
  final String? customerReview;
  final List<OrderItem> items;
  final OrderCustomer customer;
  final DateTime createdAt;

  bool get isPending => status == OrderStatus.pending;
  bool get isConfirmed => status == OrderStatus.confirmed;
  bool get isPreparing => status == OrderStatus.preparing;
  bool get isReadyForPickup => status == OrderStatus.readyForPickup;
  bool get isOutForDelivery => status == OrderStatus.outForDelivery;
  bool get isDelivered => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;

  bool get canAccept => status == OrderStatus.pending;
  bool get canReject => status == OrderStatus.pending;
  bool get canStartPreparing => status == OrderStatus.confirmed;
  bool get canMarkReady => status == OrderStatus.preparing;
  bool get canCancel => status == OrderStatus.pending || status == OrderStatus.confirmed;

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  String get estimatedPreparationTime {
    final baseTime = 15;
    final itemTime = totalItems * 2;
    return '${baseTime + itemTime} minutes';
  }

  Order copyWith({
    OrderStatus? status,
    DateTime? confirmedAt,
    DateTime? preparingAt,
    DateTime? readyAt,
    String? vendorNotes,
  }) {
    return Order(
      id: id,
      uuid: uuid,
      orderNumber: orderNumber,
      customerId: customerId,
      vendorId: vendorId,
      branchId: branchId,
      driverId: driverId,
      orderType: orderType,
      status: status ?? this.status,
      paymentStatus: paymentStatus,
      subtotal: subtotal,
      taxAmount: taxAmount,
      deliveryFee: deliveryFee,
      discountAmount: discountAmount,
      tipAmount: tipAmount,
      totalAmount: totalAmount,
      commissionAmount: commissionAmount,
      vendorEarnings: vendorEarnings,
      deliveryAddress: deliveryAddress,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      deliveryPhone: deliveryPhone,
      deliveryNotes: deliveryNotes,
      deliveryDistanceKm: deliveryDistanceKm,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      preparingAt: preparingAt ?? this.preparingAt,
      readyAt: readyAt ?? this.readyAt,
      pickedUpAt: pickedUpAt,
      deliveredAt: deliveredAt,
      cancelledAt: cancelledAt,
      scheduledFor: scheduledFor,
      customerNotes: customerNotes,
      vendorNotes: vendorNotes ?? this.vendorNotes,
      cancellationReason: cancellationReason,
      paymentMethod: paymentMethod,
      paymentTransactionId: paymentTransactionId,
      customerRating: customerRating,
      customerReview: customerReview,
      items: items,
      customer: customer,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        uuid,
        orderNumber,
        status,
        paymentStatus,
        totalAmount,
        vendorEarnings,
        confirmedAt,
        preparingAt,
        readyAt,
        vendorNotes,
      ];
}

class OrderCustomer extends Equatable {
  const OrderCustomer({
    required this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
  });

  final int id;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  @override
  List<Object?> get props => [id, firstName, lastName, phone, email];
}
