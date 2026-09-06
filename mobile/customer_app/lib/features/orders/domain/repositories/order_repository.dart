import '../../domain/entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<Order> createOrder(Map<String, dynamic> payload);
  Future<Order> trackOrder(int orderId);
}
