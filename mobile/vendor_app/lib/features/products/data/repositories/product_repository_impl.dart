import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  final ProductRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  Future<void> _ensureConnected() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
  }

  @override
  Future<List<VendorProduct>> getProducts() async {
    await _ensureConnected();
    return remoteDataSource.getProducts();
  }

  @override
  Future<VendorProduct> createProduct(Map<String, dynamic> payload) async {
    await _ensureConnected();
    return remoteDataSource.create(payload);
  }

  @override
  Future<VendorProduct> updateProduct(int id, Map<String, dynamic> payload) async {
    await _ensureConnected();
    return remoteDataSource.update(id, payload);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _ensureConnected();
    return remoteDataSource.delete(id);
  }
}
