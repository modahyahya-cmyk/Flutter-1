import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';

class ProductController extends ChangeNotifier {
  ProductController({required this.getProductsUseCase, required this.getProductDetailUseCase});

  final GetProductsUseCase getProductsUseCase;
  final GetProductDetailUseCase getProductDetailUseCase;

  bool isLoading = false;
  bool isDetailLoading = false;
  List<Product> products = [];
  Product? selectedProduct;
  Failure? failure;

  Future<void> loadProducts({Map<String, dynamic>? filters}) async {
    isLoading = true;
    failure = null;
    notifyListeners();

    try {
      products = await getProductsUseCase(filters: filters);
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    } catch (_) {
      failure = const Failure.unknown();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadDetail(int id) async {
    isDetailLoading = true;
    failure = null;
    notifyListeners();

    try {
      selectedProduct = await getProductDetailUseCase(id);
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    } catch (_) {
      failure = const Failure.unknown();
    }
    isDetailLoading = false;
    notifyListeners();
  }
}
