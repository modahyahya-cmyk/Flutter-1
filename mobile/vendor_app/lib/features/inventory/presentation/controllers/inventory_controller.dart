import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/usecases/adjust_stock_usecase.dart';
import '../../domain/usecases/get_inventory_usecase.dart';
import '../../domain/usecases/sync_inventory_usecase.dart';

class InventoryController extends ChangeNotifier {
  InventoryController({
    required this.getInventoryUseCase,
    required this.adjustStockUseCase,
    required this.syncInventoryUseCase,
  });

  final GetInventoryUseCase getInventoryUseCase;
  final AdjustStockUseCase adjustStockUseCase;
  final SyncInventoryUseCase syncInventoryUseCase;

  bool isLoading = false;
  bool isSyncing = false;
  bool isOffline = false;
  List<InventoryItem> items = [];
  Failure? failure;

  Future<void> loadInventory() async {
    isLoading = true;
    failure = null;
    notifyListeners();

    try {
      items = await getInventoryUseCase();
      isOffline = false;
    } on NetworkException {
      // still surfaces cached copy via local fallback; mark offline if empty
      items = [];
      isOffline = true;
      failure = const Failure.noConnection();
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    } catch (_) {
      failure = const Failure.unknown();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> adjustStock(int id, int delta, {String? reason}) async {
    isSyncing = true;
    failure = null;
    notifyListeners();

    try {
      await adjustStockUseCase(id, delta, reason: reason);
      await loadInventory();
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    } catch (_) {
      failure = const Failure.unknown();
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> sync() async {
    isSyncing = true;
    failure = null;
    notifyListeners();

    try {
      await syncInventoryUseCase();
      isOffline = false;
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    } catch (_) {
      failure = const Failure.unknown();
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }
}
