import '../entities/order.dart';
import '../repositories/order_repository.dart';

class RejectOrderUseCase {
  RejectOrderUseCase({required this.repository});

  final OrderRepository repository;

  Future<Order> call(int orderId, String reason) => repository.rejectOrder(orderId, reason);
}
