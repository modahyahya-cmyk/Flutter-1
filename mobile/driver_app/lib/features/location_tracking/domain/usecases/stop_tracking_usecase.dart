import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/location_repository.dart';

class StopTrackingParams {
  const StopTrackingParams();
}

class StopTrackingUseCase {
  StopTrackingUseCase({required this.repository});

  final LocationRepository repository;

  Future<Either<Failure, void>> call(StopTrackingParams params) async {
    try {
      await repository.stopTracking();
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (_) {
      return const Left(Failure.unknown());
    }
  }
}
