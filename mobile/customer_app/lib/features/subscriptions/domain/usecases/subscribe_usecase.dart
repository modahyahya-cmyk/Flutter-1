import '../../domain/entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class SubscribeUseCase {
  SubscribeUseCase({required this.repository});

  final SubscriptionRepository repository;

  Future<Subscription> call(String planCode) => repository.subscribe(planCode);
}
