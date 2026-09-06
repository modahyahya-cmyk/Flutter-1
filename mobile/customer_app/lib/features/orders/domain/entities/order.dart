import '../../../cart/domain/entities/cart_item.dart';

class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    this.totalAmount = 0,
    this.items = const [],
    this.createdAt,
  });

  final int id;
  final String orderNumber;
  final String status;
  final String paymentStatus;
  final double totalAmount;
  final List<CartItem> items;
  final DateTime? createdAt;

  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
}
