import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/delivery_repository.dart';

class SyncOfflineDeliveriesParams {
  const SyncOfflineDeliveriesParams();
}

class SyncOfflineDeliveriesUseCase {
  SyncOfflineDeliveriesUseCase({required this.repository});

  final DeliveryRepository repository;

  Future<Either<Failure, int>> call(SyncOfflineDeliveriesParams params) async {
    try {
      final synced = await repository.syncOfflineDeliveries();
      return Right(synced);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (_) {
      return const Left(Failure.unknown());
    }
  }
}
