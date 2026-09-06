import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cart.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';

class CartController extends ChangeNotifier {
  CartController({
    required this.addToCartUseCase,
    required this.removeFromCartUseCase,
    required this.getCartUseCase,
    required this.clearCartUseCase,
  });

  final AddToCartUseCase addToCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final GetCartUseCase getCartUseCase;
  final ClearCartUseCase clearCartUseCase;

  bool isLoading = false;
  bool isMutating = false;
  Cart? cart;
  Failure? failure;

  Future<void> loadCart() async {
    isLoading = true;
    failure = null;
    notifyListeners();

    try {
      cart = await getCartUseCase();
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    } catch (_) {
      failure = const Failure.unknown();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> add(int productId, int quantity, {int? variantId}) async {
    isMutating = true;
    failure = null;
    notifyListeners();

    try {
      await addToCartUseCase(productId, quantity, variantId: variantId);
      await loadCart();
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

  Future<void> remove(int cartItemId) async {
    try {
      cart = await removeFromCartUseCase(cartItemId);
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    }
    notifyListeners();
  }

  Future<void> clear() async {
    try {
      cart = await clearCartUseCase();
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    }
    notifyListeners();
  }
}
