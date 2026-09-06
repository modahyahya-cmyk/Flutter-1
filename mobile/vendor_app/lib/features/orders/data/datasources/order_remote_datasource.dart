import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/order.dart';
import '../models/order_model.dart';

class OrderRemoteDataSource {
  OrderRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  Future<List<OrderModel>> getOrders({String? status}) async {
    final data = await apiClient.get(
      ApiEndpoints.vendorOrders,
      queryParameters: status == null ? null : {'status': status},
    );
    final list = ((data as Map<String, dynamic>)['data'] as List).cast<Map<String, dynamic>>();
    return list.map(OrderModel.fromJson).toList();
  }

  Future<OrderModel> updateStatus(int orderId, OrderStatus status) async {
    final data = await apiClient.patch(
      ApiEndpoints.orderStatus(orderId),
      data: {'status': status.wire},
    );
    return OrderModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<OrderModel> reject(int orderId, String reason) async {
    final data = await apiClient.patch(
      ApiEndpoints.orderStatus(orderId),
      data: {'status': 'cancelled', 'reason': reason},
    );
    return OrderModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }
}
