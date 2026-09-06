import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';
import '../datasources/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final CartRemoteDataSource remoteDataSource;
  final CartLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Cart> getCart() async {
    if (!await networkInfo.isConnected) {
      final cached = localDataSource.getCachedCart();
      if (cached != null) return cached;
      throw const NetworkException(message: 'No internet connection');
    }

    final cart = await remoteDataSource.getCart();
    await localDataSource.cacheCart(cart);
    return cart;
  }

  @override
  Future<CartItem> addItem(int productId, int quantity, {int? variantId}) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    final item = await remoteDataSource.add(productId: productId, quantity: quantity, variantId: variantId);
    final cart = await getCart();
    await localDataSource.cacheCart(cart);
    return item;
  }

  @override
  Future<CartItem> updateItem(int cartItemId, int quantity) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    await remoteDataSource.update(cartItemId, quantity);
    final cart = await getCart();
    return cart.items.firstWhere((i) => i.id == cartItemId);
  }

  @override
  Future<Cart> removeItem(int cartItemId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    await remoteDataSource.remove(cartItemId);
    final cart = await getCart();
    await localDataSource.cacheCart(cart);
    return cart;
  }

  @override
  Future<Cart> clearCart() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    await remoteDataSource.clear();
    await localDataSource.clear();
    return const Cart(id: 0, items: []);
  }
}
