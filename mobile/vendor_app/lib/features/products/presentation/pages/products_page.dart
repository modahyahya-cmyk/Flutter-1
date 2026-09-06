import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/app_config.dart';
import '../../../../config/dependency_injection.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../controllers/product_controller.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  ProductController get _controller {
    return locator<ProductController>();
  }

  @override
  void initState() {
    super.initState();

    _controller.loadProducts();
  }

  Future<void> _delete(VendorProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete product'),
          content: Text(
            'Delete "${product.name}"? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _controller.delete(product.id);

    if (!mounted) {
      return;
    }

    if (_controller.failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mapFailureToMessage(_controller.failure!),
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product deleted'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/products/new');
        },
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_controller.failure != null &&
              _controller.products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  mapFailureToMessage(
                    _controller.failure!,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (_controller.products.isEmpty) {
            return RefreshIndicator(
              onRefresh: _controller.loadProducts,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 220),
                  Center(
                    child: Text('No products yet'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _controller.loadProducts,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _controller.products.length,
              separatorBuilder: (_, __) {
                return const SizedBox(height: 8);
              },
              itemBuilder: (context, index) {
                final product = _controller.products[index];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: product.thumbnail == null
                          ? const Icon(
                              Icons.fastfood_outlined,
                            )
                          : null,
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                      product.isActive
                          ? product.sku ?? 'Active'
                          : 'Inactive',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppConfig.formatCurrency(
                            product.price,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            context.push(
                              '/products/${product.id}/edit',
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                          ),
                          onPressed: () {
                            _delete(product);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
