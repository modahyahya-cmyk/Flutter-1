import '../entities/order.dart';
import '../repositories/order_repository.dart';

class UpdateOrderStatusUseCase {
  UpdateOrderStatusUseCase({required this.repository});

  final OrderRepository repository;

  Future<Order> call(int orderId, OrderStatus status) => repository.updateStatus(orderId, status);
}
