import 'dart:convert';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/inventory_item.dart';

class InventoryLocalDataSource {
  InventoryLocalDataSource(this.localStorage);

  final LocalStorage localStorage;

  Future<void> cache(List<InventoryItem> items) async {
    final json = items.map((e) => e.toLocalJson()).toList();
    await localStorage.saveString(StorageKeys.cachedInventory, jsonEncode(json));
  }

  List<InventoryItem> read() {
    final raw = localStorage.getString(StorageKeys.cachedInventory);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.cast<Map<String, dynamic>>().map(InventoryItem.fromLocalJson).toList();
  }
}
