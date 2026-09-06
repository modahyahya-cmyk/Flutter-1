import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/delivery.dart';
import '../repositories/delivery_repository.dart';

class AcceptDeliveryParams {
  const AcceptDeliveryParams({required this.deliveryId});

  final String deliveryId;
}

class AcceptDeliveryUseCase {
  AcceptDeliveryUseCase({required this.repository});

  final DeliveryRepository repository;

  Future<Either<Failure, Delivery>> call(AcceptDeliveryParams params) async {
    try {
      final delivery = await repository.acceptDelivery(params.deliveryId);
      return Right(delivery);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (_) {
      return const Left(Failure.unknown());
    }
  }
}
