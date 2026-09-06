import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/earnings_repository.dart';

class GetEarningsParams {
  const GetEarningsParams({this.includeOffline = false});

  final bool includeOffline;
}

class GetEarningsUseCase {
  GetEarningsUseCase({required this.repository});

  final EarningsRepository repository;

  Future<Either<Failure, EarningsData>> call(GetEarningsParams params) async {
    try {
      final data = await repository.getEarnings(includeOffline: params.includeOffline);
      return Right(data);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (_) {
      return const Left(Failure.unknown());
    }
  }
}
