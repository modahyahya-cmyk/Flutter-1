import '../../../orders/domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.status,
    required super.totalAmount,
    required super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      // تحويل آمن لمنع تعارض String و int في معرّف الطلب
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      orderNumber: json['order_number']?.toString() ??
          json['id']?.toString() ??
          '',
      status: json['status']?.toString() ?? 'PENDING',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status,
      'total_amount': totalAmount,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
