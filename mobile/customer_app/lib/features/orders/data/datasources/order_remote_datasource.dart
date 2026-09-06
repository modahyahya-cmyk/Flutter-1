import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/order_model.dart';

class OrderRemoteDataSource {
  OrderRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  Future<List<OrderModel>> getOrders() async {
    final data = await apiClient.get(ApiEndpoints.orders);
    final list = ((data as Map<String, dynamic>)['data'] as List).cast<Map<String, dynamic>>();
    return list.map(OrderModel.fromJson).toList();
  }

  Future<OrderModel> createOrder(Map<String, dynamic> payload) async {
    final data = await apiClient.post(ApiEndpoints.orders, data: payload);
    return OrderModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<OrderModel> trackOrder(int orderId) async {
    final data = await apiClient.get(ApiEndpoints.orderDetail(orderId));
    return OrderModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }
}
