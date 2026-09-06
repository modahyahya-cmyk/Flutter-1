import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/parsers.dart';
import '../../domain/entities/earnings.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../mappers/earnings_mapper.dart';

class EarningsRemoteDataSourceImpl {
  EarningsRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  Future<EarningsData> fetch() async {
    final data = await apiClient.get(ApiEndpoints.driverEarnings);
    final body = data as Map<String, dynamic>;
    final dataBlock = body['data'] as Map<String, dynamic>? ?? body;

    final list = (dataBlock['earnings'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(EarningsMapper.fromJson)
        .toList();

    return EarningsData(
      earnings: list,
      todaySummary: _summary(dataBlock['today_summary']),
      weekSummary: _summary(dataBlock['week_summary']),
      monthSummary: _summary(dataBlock['month_summary']),
    );
  }

  Future<int> sync(List<Map<String, dynamic>> payload) async {
    final data = await apiClient.post(ApiEndpoints.driverEarningsSync, data: {'earnings': payload});
    final count = (data as Map<String, dynamic>)['synced_count'] ?? 0;
    return count is num ? count.toInt() : 0;
  }

  EarningsSummary? _summary(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    return EarningsSummary(
      totalEarnings: Parsers.doubleOf(json['total_earnings']),
      totalDeliveryFees: Parsers.doubleOf(json['total_delivery_fees']),
      totalTips: Parsers.doubleOf(json['total_tips']),
      totalCommissions: Parsers.doubleOf(json['total_commissions']),
      netEarnings: Parsers.doubleOf(json['net_earnings']),
      totalDeliveries: Parsers.intOf(json['total_deliveries']),
      averageEarningPerDelivery: Parsers.doubleOf(json['average_earning_per_delivery']),
      periodStart: Parsers.dateTimeOrNull(json['period_start']) ?? DateTime.now(),
      periodEnd: Parsers.dateTimeOrNull(json['period_end']) ?? DateTime.now(),
    );
  }
}
