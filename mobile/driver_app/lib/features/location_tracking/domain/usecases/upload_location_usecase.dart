
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/location_repository.dart';

class UploadLocationParams {
  const UploadLocationParams();
}

class UploadLocationUseCase {
  UploadLocationUseCase({required this.repository});

  final LocationRepository repository;

  Future<Either<Failure, void>> call(UploadLocationParams params) async {
    try {
      await repository.uploadPendingLocations();
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (_) {
      return const Left(Failure.unknown());
    }
  }
}
