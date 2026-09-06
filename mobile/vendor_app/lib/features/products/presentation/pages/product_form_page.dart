import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../controllers/product_controller.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({
    super.key,
    this.productId,
  });

  final int? productId;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _price = TextEditingController();
  final _sku = TextEditingController();
  final _description = TextEditingController();

  late bool _active;

  bool _loadingProduct = false;
  bool _saving = false;

  bool get _isEdit => widget.productId != null;

  ProductController get _controller {
    return GetIt.instance<ProductController>();
  }

  @override
  void initState() {
    super.initState();

    _active = true;

    if (_isEdit) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    if (widget.productId == null) return;

    setState(() {
      _loadingProduct = true;
    });

    try {
      await _controller.loadProducts();

      if (!mounted) return;

      VendorProduct? product;

      for (final item in _controller.products) {
        if (item.id == widget.productId) {
          product = item;
          break;
        }
      }

      if (product != null) {
        _name.text = product.name;
        _price.text = product.price.toString();
        _sku.text = product.sku ?? '';
        _description.text = product.description ?? '';

        setState(() {
          _active = product!.isActive;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingProduct = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _sku.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = double.tryParse(_price.text.trim());

    if (price == null || price < 0) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final payload = <String, dynamic>{
      'name': _name.text.trim(),
      'price': price,
      if (_sku.text.trim().isNotEmpty) 'sku': _sku.text.trim(),
      'description': _description.text.trim(),
      'status': _active ? 'active' : 'inactive',
    };

    try {
      final result = _isEdit
          ? await _controller.update(
              widget.productId!,
              payload,
            )
          : await _controller.create(
              payload,
            );

      if (!mounted) return;

      if (result != null) {
        context.pop();
        return;
      }

      final failure = _controller.failure;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mapFailureToMessage(
              failure ?? const Failure('Save failed'),
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit product' : 'New product',
        ),
      ),
      body: _loadingProduct
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextFormField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      prefixText: r'$',
                    ),
                    validator: (value) {
                      final price = double.tryParse(
                        value?.trim() ?? '',
                      );

                      if (price == null || price < 0) {
                        return 'Enter a valid price';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _sku,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'SKU (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _description,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                    subtitle: const Text(
                      'Visibly shown in the customer catalogue',
                    ),
                    value: _active,
                    onChanged: _saving
                        ? null
                        : (value) {
                            setState(() {
                              _active = value;
                            });
                          },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
