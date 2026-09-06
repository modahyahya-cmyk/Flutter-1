import '../../domain/entities/order.dart';
import '../repositories/order_repository.dart';

class CreateOrderUseCase {
  CreateOrderUseCase({required this.repository});

  final OrderRepository repository;

  Future<Order> call(Map<String, dynamic> payload) => repository.createOrder(payload);
}
