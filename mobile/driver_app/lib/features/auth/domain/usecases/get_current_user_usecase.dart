import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/driver_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, DriverUser?>> call() async {
    try {
      final user = await repository.getCurrentUser();
      return Right(user);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (_) {
      return const Left(Failure.unknown());
    }
  }
}
