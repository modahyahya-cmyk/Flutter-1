import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/subscription_plan_model.dart';
import '../models/subscription_model.dart';

class SubscriptionRemoteDataSource {
  SubscriptionRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  Future<List<SubscriptionPlanModel>> getPlans() async {
    final data = await apiClient.get(ApiEndpoints.subscriptionPlans);
    final list = ((data as Map<String, dynamic>)['data'] as List).cast<Map<String, dynamic>>();
    return list.map(SubscriptionPlanModel.fromJson).toList();
  }

  Future<SubscriptionModel> subscribe(String planCode) async {
    final data = await apiClient.post(
      ApiEndpoints.subscriptions,
      data: {'plan_code': planCode},
    );
    return SubscriptionModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<SubscriptionModel> cancel(int subscriptionId) async {
    final data = await apiClient.post(ApiEndpoints.cancelSubscription(subscriptionId));
    return SubscriptionModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }
}
