import 'package:flutter/material.dart';

import '../../../../config/app_config.dart';
import '../../../../config/dependency_injection.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order.dart';
import '../controllers/order_controller.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _controller = getIt<OrderController>();

  @override
  void initState() {
    super.initState();
    _controller.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_controller.failure != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mapFailureToMessage(_controller.failure!),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _controller.loadOrders,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_controller.orders.isEmpty) {
            return const Center(
              child: Text('No orders yet.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _controller.orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final Order order = _controller.orders[i];

              return Card(
                child: ListTile(
                  title: Text(order.orderNumber),
                  subtitle: Text('${order.items.length} item(s)'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppConfig.formatCurrency(order.totalAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _statusChip(order.status),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusChip(String status) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppConfig.INFO_COLOR.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          color: AppConfig.INFO_COLOR,
        ),
      ),
    );
  }
}
