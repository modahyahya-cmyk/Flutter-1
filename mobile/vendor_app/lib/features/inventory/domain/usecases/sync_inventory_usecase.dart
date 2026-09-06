import '../repositories/inventory_repository.dart';

class SyncInventoryUseCase {
  SyncInventoryUseCase({required this.repository});

  final InventoryRepository repository;

  Future<void> call() => repository.sync();
}
