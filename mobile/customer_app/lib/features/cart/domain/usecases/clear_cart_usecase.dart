import '../../domain/entities/cart.dart';
import '../repositories/cart_repository.dart';

class ClearCartUseCase {
  ClearCartUseCase({required this.repository});

  final CartRepository repository;

  Future<Cart> call() => repository.clearCart();
}
