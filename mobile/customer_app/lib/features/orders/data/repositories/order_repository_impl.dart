import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  final OrderRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<List<Order>> getOrders() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    return remoteDataSource.getOrders();
  }

  @override
  Future<Order> createOrder(Map<String, dynamic> payload) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    return remoteDataSource.createOrder(payload);
  }

  @override
  Future<Order> trackOrder(int orderId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    return remoteDataSource.trackOrder(orderId);
  }
}
