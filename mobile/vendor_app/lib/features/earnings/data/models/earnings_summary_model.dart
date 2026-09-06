import '../../../../core/utils/parsers.dart';
import '../../domain/entities/earnings_summary.dart';

class EarningsSummaryModel extends EarningsSummary {
  const EarningsSummaryModel({
    required super.todayEarnings,
    required super.weekEarnings,
    required super.monthEarnings,
    required super.totalEarnings,
    required super.totalOrders,
    super.todayOrders,
    super.weekOrders,
    super.monthOrders,
    super.averageOrderValue,
    required super.lastUpdated,
  });

  factory EarningsSummaryModel.fromJson(Map<String, dynamic> json) {
    return EarningsSummaryModel(
      todayEarnings: Parsers.doubleOf(json['today_earnings']),
      weekEarnings: Parsers.doubleOf(json['week_earnings']),
      monthEarnings: Parsers.doubleOf(json['month_earnings']),
      totalEarnings: Parsers.doubleOf(json['total_earnings']),
      totalOrders: Parsers.intOf(json['total_orders']),
      todayOrders: Parsers.intOf(json['today_orders']),
      weekOrders: Parsers.intOf(json['week_orders']),
      monthOrders: Parsers.intOf(json['month_orders']),
      averageOrderValue: Parsers.doubleOf(json['average_order_value']),
      lastUpdated: Parsers.dateTimeOrNull(json['last_updated']) ?? DateTime.now(),
    );
  }
}
