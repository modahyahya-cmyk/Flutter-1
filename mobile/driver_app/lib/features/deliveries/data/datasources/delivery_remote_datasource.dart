import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/delivery.dart';
import '../models/delivery_model.dart';

class DeliveryRemoteDataSourceImpl {
  DeliveryRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  Future<List<DeliveryModel>> getAssigned({String? status}) async {
    final data = await apiClient.get(
      ApiEndpoints.driverDeliveries,
      queryParameters: status == null ? null : {'status': status},
    );
    final list = ((data as Map<String, dynamic>)['data'] as List).cast<Map<String, dynamic>>();
    return list.map(DeliveryModel.fromJson).toList();
  }

  Future<DeliveryModel> accept(String deliveryId) async {
    final data = await apiClient.post(ApiEndpoints.deliveryAccept(deliveryId));
    return DeliveryModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<DeliveryModel> updateStatus(String deliveryId, DeliveryStatus status) async {
    final data = await apiClient.patch(
      ApiEndpoints.deliveryStatus(deliveryId),
      data: {'status': status.wire},
    );
    return DeliveryModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<DeliveryModel> complete(
    String deliveryId, {
    String? proofImage,
    String? notes,
  }) async {
    final data = await apiClient.post(
      ApiEndpoints.deliveryComplete(deliveryId),
      data: {
        if (proofImage != null) 'proof_image': proofImage,
        if (notes != null) 'notes': notes,
      },
    );
    return DeliveryModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<int> sync(List<Map<String, dynamic>> payload) async {
    final data = await apiClient.post(ApiEndpoints.deliveriesSync, data: {'deliveries': payload});
    final count = (data as Map<String, dynamic>)['synced_count'] ?? 0;
    return count is num ? count.toInt() : 0;
  }
}
