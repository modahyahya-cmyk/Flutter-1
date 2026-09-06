import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/earnings_summary.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../datasources/earnings_remote_datasource.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  EarningsRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  final EarningsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<EarningsSummary> getEarningsSummary() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    return remoteDataSource.getSummary();
  }
}
