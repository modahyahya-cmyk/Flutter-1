import '../entities/inventory_item.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventory();
  Future<void> adjustStock(int id, int delta, {String? reason});
  Future<void> sync();
  List<InventoryItem> getCachedInventory();
}
