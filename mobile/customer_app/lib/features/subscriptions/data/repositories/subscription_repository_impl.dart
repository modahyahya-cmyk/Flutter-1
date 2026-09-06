import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  final SubscriptionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<List<SubscriptionPlan>> getPlans() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    return remoteDataSource.getPlans();
  }

  @override
  Future<Subscription> subscribe(String planCode) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    return remoteDataSource.subscribe(planCode);
  }

  @override
  Future<Subscription> cancelSubscription(int subscriptionId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    return remoteDataSource.cancel(subscriptionId);
  }
}
