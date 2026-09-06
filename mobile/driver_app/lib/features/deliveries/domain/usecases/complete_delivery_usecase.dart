import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/delivery.dart';
import '../repositories/delivery_repository.dart';

class CompleteDeliveryParams {
  const CompleteDeliveryParams({required this.deliveryId, this.proofImage, this.notes});

  final String deliveryId;
  final String? proofImage;
  final String? notes;
}

class CompleteDeliveryUseCase {
  CompleteDeliveryUseCase({required this.repository});

  final DeliveryRepository repository;

  Future<Either<Failure, Delivery>> call(CompleteDeliveryParams params) async {
    try {
      final delivery = await repository.completeDelivery(
        params.deliveryId,
        proofImage: params.proofImage,
        notes: params.notes,
      );
      return Right(delivery);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (_) {
      return const Left(Failure.unknown());
    }
  }
}
