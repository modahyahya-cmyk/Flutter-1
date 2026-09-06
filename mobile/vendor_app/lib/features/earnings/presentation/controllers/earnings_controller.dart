import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/earnings_summary.dart';
import '../../domain/usecases/get_earnings_summary_usecase.dart';

class EarningsController extends ChangeNotifier {
  EarningsController({required this.getEarningsSummaryUseCase});

  final GetEarningsSummaryUseCase getEarningsSummaryUseCase;

  bool isLoading = false;
  EarningsSummary? summary;
  Failure? failure;

  Future<void> load() async {
    isLoading = true;
    failure = null;
    notifyListeners();

    try {
      summary = await getEarningsSummaryUseCase();
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    } catch (_) {
      failure = const Failure.unknown();
    }
    isLoading = false;
    notifyListeners();
  }
}
