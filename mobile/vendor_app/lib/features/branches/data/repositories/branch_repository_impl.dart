import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/branch.dart';
import '../../domain/repositories/branch_repository.dart';
import '../datasources/branch_remote_datasource.dart';

class BranchRepositoryImpl implements BranchRepository {
  BranchRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  final BranchRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  Future<void> _ensureConnected() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
  }

  @override
  Future<List<VendorBranch>> getBranches() async {
    await _ensureConnected();
    return remoteDataSource.getBranches();
  }

  @override
  Future<VendorBranch> createBranch(Map<String, dynamic> payload) async {
    await _ensureConnected();
    return remoteDataSource.create(payload);
  }

  @override
  Future<VendorBranch> updateBranch(int id, Map<String, dynamic> payload) async {
    await _ensureConnected();
    return remoteDataSource.update(id, payload);
  }
}
