import '../../domain/entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class CancelSubscriptionUseCase {
  CancelSubscriptionUseCase({required this.repository});

  final SubscriptionRepository repository;

  Future<Subscription> call(int subscriptionId) => repository.cancelSubscription(subscriptionId);
}
