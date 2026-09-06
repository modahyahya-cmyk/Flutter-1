import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';

class ProductController extends ChangeNotifier {
  ProductController({
    required this.getProductsUseCase,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
  });

  final GetProductsUseCase getProductsUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;

  bool isLoading = false;
  bool isMutating = false;
  List<VendorProduct> products = [];
  Failure? failure;

  Future<void> loadProducts() async {
    isLoading = true;
    failure = null;
    notifyListeners();

    try {
      products = await getProductsUseCase();
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    } catch (_) {
      failure = const Failure.unknown();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<VendorProduct?> create(Map<String, dynamic> payload) async =>
      _mutate(() => createProductUseCase(payload));

  Future<VendorProduct?> update(int id, Map<String, dynamic> payload) async =>
      _mutate(() => updateProductUseCase(id, payload));

  Future<bool> delete(int id) async {
    isMutating = true;
    failure = null;
    notifyListeners();

    try {
      await deleteProductUseCase(id);
      products.removeWhere((p) => p.id == id);
      return true;
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
      return false;
    } catch (_) {
      failure = const Failure.unknown();
      return false;
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }

  Future<VendorProduct?> _mutate(Future<VendorProduct> Function() action) async {
    isMutating = true;
    failure = null;
    notifyListeners();

    try {
      final result = await action();
      final index = products.indexWhere((p) => p.id == result.id);
      if (index >= 0) {
        products[index] = result;
      } else {
        products.add(result);
      }
      return result;
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
      return null;
    } catch (_) {
      failure = const Failure.unknown();
      return null;
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }
}
