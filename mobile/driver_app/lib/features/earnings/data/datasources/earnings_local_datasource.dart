import '../../../../core/storage/isar_service.dart';
import '../../domain/entities/earnings.dart';
import '../mappers/earnings_mapper.dart';

class EarningsLocalDataSourceImpl {
  EarningsLocalDataSourceImpl({required this.isarService});

  final IsarService isarService;

  Future<void> saveAll(List<Earnings> earnings, {bool isSynced = false}) async {
    final models = earnings.map((e) => EarningsMapper.toLocal(e, isSynced: isSynced)).toList();
    for (final m in models) {
      await isarService.saveEarning(m);
    }
  }

  Future<List<Earnings>> getAll() async {
    final models = await isarService.getAllEarnings();
    return models.map(EarningsMapper.fromLocal).toList();
  }

  Future<List<Earnings>> getByDateRange(DateTime start, DateTime end) async {
    final models = await isarService.getEarningsByDateRange(start, end);
    return models.map(EarningsMapper.fromLocal).toList();
  }

  Future<double> getTotal() => isarService.getTotalEarnings();

  Future<int> getCount() async => (await isarService.getAllEarnings()).length;
}
