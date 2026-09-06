import '../../domain/entities/subscription_plan.dart';
import '../repositories/subscription_repository.dart';

class GetPlansUseCase {
  GetPlansUseCase({required this.repository});

  final SubscriptionRepository repository;

  Future<List<SubscriptionPlan>> call() => repository.getPlans();
}
