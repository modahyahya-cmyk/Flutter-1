import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  final OrderRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  Future<void> _ensureConnected() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
  }

  @override
  Future<List<Order>> getOrders({String? status}) async {
    await _ensureConnected();
    return remoteDataSource.getOrders(status: status);
  }

  @override
  Future<Order> acceptOrder(int orderId) async {
    await _ensureConnected();
    return remoteDataSource.updateStatus(orderId, OrderStatus.confirmed);
  }

  @override
  Future<Order> rejectOrder(int orderId, String reason) async {
    await _ensureConnected();
    return remoteDataSource.reject(orderId, reason);
  }

  @override
  Future<Order> updateStatus(int orderId, OrderStatus status) async {
    await _ensureConnected();
    return remoteDataSource.updateStatus(orderId, status);
  }
}
