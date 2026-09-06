import '../../domain/entities/order.dart';
import '../repositories/order_repository.dart';

class TrackOrderUseCase {
  TrackOrderUseCase({required this.repository});

  final OrderRepository repository;

  Future<Order> call(int orderId) => repository.trackOrder(orderId);
}
