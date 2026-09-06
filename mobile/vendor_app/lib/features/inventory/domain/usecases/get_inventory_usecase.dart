import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class GetInventoryUseCase {
  GetInventoryUseCase({required this.repository});

  final InventoryRepository repository;

  Future<List<InventoryItem>> call() => repository.getInventory();
}
