import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  OrderController get _controller => locator<OrderController>();
  OrderStatus? _filter;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() => _controller.loadOrders(status: _filter?.wire);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              children: [
                _buildFilterBar(),
                Expanded(
                  child: _controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _controller.failure != null
                          ? _buildError()
                          : _controller.orders.isEmpty
                              ? const Center(child: Text('No orders yet'))
                              : ListView.separated(
                                  padding: const EdgeInsets.all(12),
                                  itemCount: _controller.orders.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemBuilder: (context, i) => _OrderCard(order: _controller.orders[i]),
                                ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    final options = <OrderStatus?>[null, ...OrderStatus.values];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final status = options[i];
          final selected = _filter == status;
          return ChoiceChip(
            label: Text(status?.label ?? 'All'),
            selected: selected,
            onSelected: (_) {
              setState(() => _filter = status);
              _refresh();
            },
          );
        },
      ),
    );
  }

  Widget _buildError() =>
      Center(child: Text(mapFailureToMessage(_controller.failure!)));
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  Color _statusColor(OrderStatus s) => switch (s) {
        OrderStatus.pending => AppConfig.WARNING_COLOR,
        OrderStatus.confirmed => AppConfig.INFO_COLOR,
        OrderStatus.preparing => AppConfig.ACCENT_COLOR,
        OrderStatus.readyForPickup => AppConfig.SECONDARY_COLOR,
        OrderStatus.outForDelivery => AppConfig.INFO_COLOR,
        OrderStatus.delivered => AppConfig.SUCCESS_COLOR,
        OrderStatus.cancelled || OrderStatus.refunded => AppConfig.ERROR_COLOR,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/orders/${order.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('#${order.orderNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(order.status.label,
                        style: TextStyle(color: _statusColor(order.status), fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(child: Text(order.customer.fullName.isEmpty ? 'Customer' : order.customer.fullName)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text('${order.totalItems} items', style: TextStyle(color: Colors.grey.shade600)),
                  const Spacer(),
                  Text(AppConfig.formatCurrency(order.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
