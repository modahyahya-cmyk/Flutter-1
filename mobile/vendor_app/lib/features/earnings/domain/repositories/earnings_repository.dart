import '../entities/earnings_summary.dart';

abstract class EarningsRepository {
  Future<EarningsSummary> getEarningsSummary();
}
