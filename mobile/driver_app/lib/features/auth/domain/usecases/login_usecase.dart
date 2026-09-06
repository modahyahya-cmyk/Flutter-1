import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  LoginUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, AuthSession>> call(String phone, String password) async {
    try {
      final session = await repository.login(phone, password);
      return Right(session);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (_) {
      return const Left(Failure.unknown());
    }
  }
}
