import 'cart_item.dart';

class Cart {
  const Cart({
    required this.id,
    required this.items,
    this.subtotal = 0,
    this.taxAmount = 0,
    this.totalAmount = 0,
  });

  final int id;
  final List<CartItem> items;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;
}
