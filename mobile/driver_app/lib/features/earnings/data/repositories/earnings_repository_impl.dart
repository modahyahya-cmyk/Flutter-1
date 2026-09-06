import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/earnings.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../datasources/earnings_local_datasource.dart';
import '../datasources/earnings_remote_datasource.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  EarningsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final EarningsRemoteDataSourceImpl remoteDataSource;
  final EarningsLocalDataSourceImpl localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<EarningsData> getEarnings({bool includeOffline = false}) async {
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.fetch();
        await localDataSource.saveAll(remote.earnings, isSynced: true);
        return remote;
      } on AppException catch (e) {
        AppLogger.warning('Failed to fetch earnings, using offline ledger', data: {'error': e.message});
        if (!includeOffline) rethrow;
      }
    }

    if (!includeOffline) throw const OfflineException();

    final cached = await localDataSource.getAll();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));

    return EarningsData(
      earnings: cached,
      todaySummary: _buildSummary(cached, todayStart, now),
      weekSummary: _buildSummary(cached, weekStart, now),
      monthSummary: _buildSummary(cached, DateTime(now.year, now.month, 1), now),
    );
  }

  @override
  Future<int> syncEarnings() async {
    if (!await networkInfo.isConnected) return 0;

    final local = await localDataSource.getAll();
    final payload = local
        .map((e) => {
              'earning_id': e.id,
              'delivery_id': e.deliveryId,
              'order_number': e.orderNumber,
              'amount': e.totalEarnings,
              'date': e.date.toIso8601String(),
              'status': e.status.wire,
            })
        .toList();

    if (payload.isEmpty) return 0;

    try {
      final synced = await remoteDataSource.sync(payload);
      // Pull authoritative ledger after pushing.
      final remote = await remoteDataSource.fetch();
      await localDataSource.saveAll(remote.earnings, isSynced: true);
      return synced;
    } on AppException catch (e) {
      AppLogger.warning('Earnings sync failed', data: {'error': e.message});
      rethrow;
    }
  }

  EarningsSummary _buildSummary(List<Earnings> earnings, DateTime start, DateTime end) {
    final inRange = earnings.where((e) => !e.date.isBefore(start) && !e.date.isAfter(end)).toList();
    final total = inRange.fold(0.0, (s, e) => s + e.totalEarnings);
    final fees = inRange.fold(0.0, (s, e) => s + e.deliveryFee);
    final tips = inRange.fold(0.0, (s, e) => s + e.tipAmount);
    final commissions = inRange.fold(0.0, (s, e) => s + e.platformCommission);

    return EarningsSummary(
      totalEarnings: total,
      totalDeliveryFees: fees,
      totalTips: tips,
      totalCommissions: commissions,
      netEarnings: total - commissions,
      totalDeliveries: inRange.length,
      averageEarningPerDelivery: inRange.isEmpty ? 0 : total / inRange.length,
      periodStart: start,
      periodEnd: end,
    );
  }
}
