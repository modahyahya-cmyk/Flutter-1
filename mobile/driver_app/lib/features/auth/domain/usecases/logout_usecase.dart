import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  LogoutUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, void>> call() async {
    try {
      await repository.logout();
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (_) {
      return const Left(Failure.unknown());
    }
  }
}
