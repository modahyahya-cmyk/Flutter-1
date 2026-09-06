import '../entities/earnings_summary.dart';
import '../repositories/earnings_repository.dart';

class GetEarningsSummaryUseCase {
  GetEarningsSummaryUseCase({required this.repository});

  final EarningsRepository repository;

  Future<EarningsSummary> call() => repository.getEarningsSummary();
}
