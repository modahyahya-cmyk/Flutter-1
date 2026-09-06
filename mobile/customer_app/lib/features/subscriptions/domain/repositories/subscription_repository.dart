import '../../domain/entities/subscription.dart';
import '../../domain/entities/subscription_plan.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlan>> getPlans();
  Future<Subscription> subscribe(String planCode);
  Future<Subscription> cancelSubscription(int subscriptionId);
}
