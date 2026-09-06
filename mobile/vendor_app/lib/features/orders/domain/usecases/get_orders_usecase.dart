import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  GetOrdersUseCase({required this.repository});

  final OrderRepository repository;

  Future<List<Order>> call({String? status}) => repository.getOrders(status: status);
}
