import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/location_repository.dart';

class StartTrackingParams {
  const StartTrackingParams({this.deliveryId});

  final String? deliveryId;
}

class StartTrackingUseCase {
  StartTrackingUseCase({required this.repository});

  final LocationRepository repository;

  Future<Either<Failure, bool>> call(StartTrackingParams params) async {
    try {
      final started = await repository.startTracking(deliveryId: params.deliveryId);
      return Right(started);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (_) {
      return const Left(Failure.unknown());
    }
  }
}
