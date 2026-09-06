import '../repositories/inventory_repository.dart';

class AdjustStockUseCase {
  AdjustStockUseCase({required this.repository});

  final InventoryRepository repository;

  Future<void> call(int id, int delta, {String? reason}) =>
      repository.adjustStock(id, delta, reason: reason);
}
