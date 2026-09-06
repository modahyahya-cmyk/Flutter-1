import '../entities/order.dart';
import '../repositories/order_repository.dart';

class AcceptOrderUseCase {
  AcceptOrderUseCase({required this.repository});

  final OrderRepository repository;

  Future<Order> call(int orderId) => repository.acceptOrder(orderId);
}
