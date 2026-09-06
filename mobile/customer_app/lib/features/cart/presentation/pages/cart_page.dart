import 'package:flutter/material.dart';

import '../../../../config/app_config.dart';
import '../../../../config/dependency_injection.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cart_item.dart';
import '../controllers/cart_controller.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _controller = getIt<CartController>();

  @override
  void initState() {
    super.initState();
    _controller.loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.failure != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mapFailureToMessage(_controller.failure!),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _controller.loadCart,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final cart = _controller.cart;

          if (cart == null || cart.isEmpty) {
            return const _EmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final CartItem item = cart.items[i];

                    return _CartItemTile(
                      item: item,
                      onIncrease: () => _controller.add(
                        item.productId,
                        item.quantity + 1,
                        variantId: item.variantId,
                      ),
                      onDecrease: () {
                        if (item.quantity <= 1) {
                          _controller.remove(item.id);
                        } else {
                          _controller.add(
                            item.productId,
                            item.quantity - 1,
                            variantId: item.variantId,
                          );
                        }
                      },
                      onRemove: () => _controller.remove(item.id),
                    );
                  },
                ),
              ),
              _TotalsFooter(
                subtotal: cart.subtotal,
                tax: cart.taxAmount,
                total: cart.totalAmount,
                clearCart: _controller.clear,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final image = item.productImage ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: image.isEmpty
                    ? ColoredBox(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Icon(Icons.image),
                      )
                    : Image.network(image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName ?? 'Item',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConfig.formatCurrency(item.unitPrice),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            _QtyControl(
              quantity: item.quantity,
              onDecrease: onDecrease,
              onIncrease: onIncrease,
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.delete_outline,
                color: AppConfig.ERROR_COLOR,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  const _QtyControl({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: onDecrease,
        ),
        Text(
          '$quantity',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: onIncrease,
        ),
      ],
    );
  }
}

class _TotalsFooter extends StatelessWidget {
  const _TotalsFooter({
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.clearCart,
  });

  final double subtotal;
  final double tax;
  final double total;
  final Future<void> Function() clearCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row('Subtotal', subtotal),
          _row('Tax', tax),
          const Divider(),
          _row('Total', total, bold: true),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              await clearCart();
            },
            child: const Text('Clear Cart'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w700 : null,
            ),
          ),
          Text(
            AppConfig.formatCurrency(value),
            style: TextStyle(
              fontWeight: bold ? FontWeight.w700 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppConfig.INFO_COLOR,
          ),
          SizedBox(height: 16),
          Text('Your cart is empty'),
        ],
      ),
    );
  }
}
