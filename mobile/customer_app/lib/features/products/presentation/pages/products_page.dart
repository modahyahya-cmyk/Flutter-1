import 'package:flutter/material.dart';

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
  final _controller = getIt<ProductController>();

  @override
  void initState() {
    super.initState();
    _controller.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.failure != null) {
            return Center(child: Text(mapFailureToMessage(_controller.failure!)));
          }
          if (_controller.products.isEmpty) {
            return const Center(child: Text('No products found.'));
          }
          return ListView.separated(
            itemCount: _controller.products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final Product p = _controller.products[i];
              return ListTile(
                leading: _thumb(p.primaryImage),
                title: Text(p.name),
                subtitle: Text(p.formattedPrice ?? p.price.toString()),
                onTap: () => _openDetail(p.id),
              );
            },
          );
        },
      ),
    );
  }

  Widget _thumb(String url) {
    return SizedBox(
      width: 56,
      height: 56,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: url.isEmpty
            ? ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image),
              )
            : Image.network(url, width: 56, height: 56, fit: BoxFit.cover),
      ),
    );
  }

  Future<void> _openDetail(int id) async {
    await _controller.loadDetail(id);
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      builder: (_) => _controller.selectedProduct == null
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _controller.selectedProduct!.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _controller.selectedProduct!.shortDescription ?? '',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
    );
  }
}
