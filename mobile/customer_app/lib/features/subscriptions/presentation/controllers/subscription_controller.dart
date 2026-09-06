import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/usecases/cancel_subscription_usecase.dart';
import '../../domain/usecases/get_plans_usecase.dart';
import '../../domain/usecases/subscribe_usecase.dart';

class SubscriptionController extends ChangeNotifier {
  SubscriptionController({
    required this.getPlansUseCase,
    required this.subscribeUseCase,
    required this.cancelSubscriptionUseCase,
  });

  final GetPlansUseCase getPlansUseCase;
  final SubscribeUseCase subscribeUseCase;
  final CancelSubscriptionUseCase cancelSubscriptionUseCase;

  bool isLoading = false;
  bool isSubscribing = false;
  List<SubscriptionPlan> plans = [];
  Subscription? currentSubscription;
  Failure? failure;

  Future<void> loadPlans() async {
    isLoading = true;
    failure = null;
    notifyListeners();

    try {
      plans = await getPlansUseCase();
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    } catch (_) {
      failure = const Failure.unknown();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> subscribe(String planCode) async {
    isSubscribing = true;
    failure = null;
    notifyListeners();

    try {
      currentSubscription = await subscribeUseCase(planCode);
      return true;
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
      return false;
    } catch (_) {
      failure = const Failure.unknown();
      return false;
    } finally {
      isSubscribing = false;
      notifyListeners();
    }
  }

  Future<void> cancel(int subscriptionId) async {
    try {
      currentSubscription = await cancelSubscriptionUseCase(subscriptionId);
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    }
    notifyListeners();
  }
}
