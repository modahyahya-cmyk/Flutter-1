import 'package:equatable/equatable.dart';

import '../entities/earnings.dart';

class EarningsData extends Equatable {
  const EarningsData({
    required this.earnings,
    this.todaySummary,
    this.weekSummary,
    this.monthSummary,
  });

  final List<Earnings> earnings;
  final EarningsSummary? todaySummary;
  final EarningsSummary? weekSummary;
  final EarningsSummary? monthSummary;

  @override
  List<Object?> get props => [earnings, todaySummary, weekSummary, monthSummary];
}

abstract class EarningsRepository {
  Future<EarningsData> getEarnings({bool includeOffline = false});
  Future<int> syncEarnings();
}
