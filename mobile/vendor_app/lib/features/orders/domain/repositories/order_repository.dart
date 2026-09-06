import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders({String? status});

  Future<Order> acceptOrder(int orderId);

  Future<Order> rejectOrder(int orderId, String reason);

  Future<Order> updateStatus(int orderId, OrderStatus status);
}
