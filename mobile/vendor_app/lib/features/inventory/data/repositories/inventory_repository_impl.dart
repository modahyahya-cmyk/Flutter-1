import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_local_datasource.dart';
import '../datasources/inventory_remote_datasource.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final InventoryRemoteDataSource remoteDataSource;
  final InventoryLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<List<InventoryItem>> getInventory() async {
    if (await networkInfo.isConnected) {
      try {
        final raw = await remoteDataSource.fetchInventory();
        final items = raw
            .map((j) => InventoryItem(
                  id: j['id'] as int,
                  name: j['name'] as String,
                  sku: j['sku'] as String? ?? '',
                  quantity: _quantityOf(j),
                  unit: j['unit'] as String?,
                  minStockLevel: j['min_stock_level'] as int? ?? 0,
                  price: (j['price'] as num?)?.toDouble(),
                ))
            .toList();
        await localDataSource.cache(items);
        return items;
      } on AppException {
        // fall through to cached copy
      }
    }
    return localDataSource.read();
  }

  @override
  Future<void> adjustStock(int id, int delta, {String? reason}) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'Cannot adjust stock offline');
    }
    await remoteDataSource.adjustStock(id, delta, reason: reason);
    // refresh cache for single item is approximated by full reload below
    await getInventory();
  }

  @override
  Future<void> sync() async {
    await getInventory();
  }

  @override
  List<InventoryItem> getCachedInventory() => localDataSource.read();

  int _quantityOf(Map<String, dynamic> j) {
    if (j['quantity'] is num) return (j['quantity'] as num).toInt();
    if (j['stock_quantity'] is num) return (j['stock_quantity'] as num).toInt();
    return 0;
  }
}
