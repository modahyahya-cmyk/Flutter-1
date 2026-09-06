import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/delivery.dart';
import '../repositories/delivery_repository.dart';

class GetDeliveriesParams {
  const GetDeliveriesParams({this.includeOffline = false});

  final bool includeOffline;
}

class GetDeliveriesUseCase {
  GetDeliveriesUseCase({required this.repository});

  final DeliveryRepository repository;

  Future<Either<Failure, List<Delivery>>> call(GetDeliveriesParams params) async {
    try {
      final deliveries = await repository.getDeliveries(includeOffline: params.includeOffline);
      return Right(deliveries);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (_) {
      return const Left(Failure.unknown());
    }
  }
}
