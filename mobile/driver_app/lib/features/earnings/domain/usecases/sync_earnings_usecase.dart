import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/earnings_repository.dart';

class SyncEarningsParams {
  const SyncEarningsParams();
}

class SyncEarningsUseCase {
  SyncEarningsUseCase({required this.repository});

  final EarningsRepository repository;

  Future<Either<Failure, int>> call(SyncEarningsParams params) async {
    try {
      final synced = await repository.syncEarnings();
      return Right(synced);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (_) {
      return const Left(Failure.unknown());
    }
  }
}
