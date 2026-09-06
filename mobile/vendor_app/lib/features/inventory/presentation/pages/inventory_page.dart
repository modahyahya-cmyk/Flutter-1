import 'package:flutter/material.dart';

import '../../../../config/app_config.dart';
import '../../../../config/dependency_injection.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/inventory_item.dart';
import '../controllers/inventory_controller.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  InventoryController get _controller => locator<InventoryController>();

  @override
  void initState() {
    super.initState();
    _controller.loadInventory();
  }

  Future<void> _adjust(InventoryItem item, int delta) async {
    await _controller.adjustStock(item.id, delta, reason: delta < 0 ? 'Manual correction' : 'Restock');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          if (_controller.isOffline)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Chip(avatar: Icon(Icons.cloud_off, size: 16), label: Text('Offline')),
            ),
          IconButton(
            tooltip: 'Sync',
            icon: _controller.isSyncing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync),
            onPressed: _controller.isSyncing ? null : _controller.sync,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.failure != null && _controller.items.isEmpty) {
            return Center(child: Text(mapFailureToMessage(_controller.failure!)));
          }
          if (_controller.items.isEmpty) {
            return const Center(child: Text('No inventory records'));
          }
          return RefreshIndicator(
            onRefresh: _controller.loadInventory,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _controller.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = _controller.items[i];
                final color = item.isOutOfStock
                    ? AppConfig.ERROR_COLOR
                    : item.isLowStock
                        ? AppConfig.WARNING_COLOR
                        : AppConfig.SUCCESS_COLOR;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: color, child: Text('${item.quantity}')),
                    title: Text(item.name),
                    subtitle: Text(item.sku),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: item.quantity > 0 ? () => _adjust(item, -1) : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _adjust(item, 1),
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
