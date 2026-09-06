import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  final ProductRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<List<Product>> getProducts({Map<String, dynamic>? filters}) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    return remoteDataSource.getProducts(filters: filters);
  }

  @override
  Future<Product> getProductDetail(int id) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    return remoteDataSource.getProductDetail(id);
  }

  Future<List<Product>> getFeatured() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    return remoteDataSource.getFeatured();
  }
}
