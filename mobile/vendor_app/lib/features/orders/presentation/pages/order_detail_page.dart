import 'package:flutter/material.dart';

import '../../../../config/app_config.dart';
import '../../../../config/dependency_injection.dart';
import '../../../../core/errors/failures.dart';
import '../../../thermal_printing/presentation/controllers/printer_controller.dart';
import '../../domain/entities/order.dart';
import '../controllers/order_controller.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  OrderController get _controller => locator<OrderController>();

  @override
  void initState() {
    super.initState();
    // Ensure the order is present in the in-memory collection.
    if (_controller.orders.isEmpty || !_controller.orders.any((o) => o.id == widget.orderId)) {
      _controller.loadOrders();
    }
  }

  Order? get _order {
    for (final o in _controller.orders) {
      if (o.id == widget.orderId) return o;
    }
    return null;
  }

  Future<void> _print(Order order) async {
    final printer = locator<PrinterController>();
    if (!printer.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect a printer first (Printer tab)')),
      );
      return;
    }
    final ok = await printer.printOrder(order);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Receipt sent to printer' : 'Print failed')),
    );
  }

  Future<void> _confirmReject(Order order) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final text = TextEditingController();
        return AlertDialog(
          title: const Text('Reject order'),
          content: TextField(
            controller: text,
            decoration: const InputDecoration(labelText: 'Reason (optional)'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, text.text.trim()), child: const Text('Reject')),
          ],
        );
      },
    );
    if (reason == null) return;
    await _controller.reject(order.id, reason);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order rejected')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_order == null ? 'Order #${widget.orderId}' : 'Order #${_order!.orderNumber}')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _order == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final order = _order;
          if (order == null) {
            return Center(child: Text(mapFailureToMessage(_controller.failure ?? const Failure('Order not found'))));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusSection(order: order),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Items',
                child: Column(
                  children: [
                    for (final item in order.items)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.menu_book_outlined),
                        title: Text(item.productName),
                        subtitle: item.variantName != null ? Text(item.variantName!) : null,
                        trailing: Text('${item.quantity} × ${AppConfig.formatCurrency(item.unitPrice)}'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Summary',
                child: Column(
                  children: [
                    _row('Subtotal', AppConfig.formatCurrency(order.subtotal)),
                    _row('Tax', AppConfig.formatCurrency(order.taxAmount)),
                    _row('Delivery fee', AppConfig.formatCurrency(order.deliveryFee)),
                    if (order.discountAmount > 0)
                      _row('Discount', '-${AppConfig.formatCurrency(order.discountAmount)}'),
                    if (order.tipAmount > 0) _row('Tip', AppConfig.formatCurrency(order.tipAmount)),
                    const Divider(),
                    _row('Total', AppConfig.formatCurrency(order.totalAmount), bold: true),
                    _row('Your earnings', AppConfig.formatCurrency(order.vendorEarnings)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Customer',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.customer.fullName.isEmpty ? 'Customer #${order.customerId}' : order.customer.fullName),
                    if (order.customer.phone != null) Text(order.customer.phone!),
                    if (order.deliveryAddress != null) Text(order.deliveryAddress!),
                    Text('Order type: ${order.orderType.name}', style: TextStyle(color: Colors.grey.shade600)),
                    Text('Payment: ${order.paymentStatus.name}', style: TextStyle(color: Colors.grey.shade600)),
                    if (order.customerNotes != null) Text('Notes: ${order.customerNotes}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildActions(order),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActions(Order order) {
    final controller = _controller;
    final busy = controller.isMutating;
    return Column(
      children: [
        if (order.canAccept)
          FilledButton(
            onPressed: busy ? null : () => controller.accept(order.id),
            child: const Text('Accept order'),
          ),
        if (order.canReject) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: busy ? null : () => _confirmReject(order),
            style: OutlinedButton.styleFrom(foregroundColor: AppConfig.ERROR_COLOR),
            child: const Text('Reject order'),
          ),
        ],
        if (order.canStartPreparing) ...[
          const SizedBox(height: 8),
          FilledButton(onPressed: busy ? null : () => controller.advanceStatus(order.id, OrderStatus.preparing), child: const Text('Start preparing')),
        ],
        if (order.canMarkReady) ...[
          const SizedBox(height: 8),
          FilledButton(onPressed: busy ? null : () => controller.advanceStatus(order.id, OrderStatus.readyForPickup), child: const Text('Mark ready')),
        ],
        if (order.status == OrderStatus.readyForPickup) ...[
          const SizedBox(height: 8),
          OutlinedButton(onPressed: busy ? null : () => controller.advanceStatus(order.id, OrderStatus.outForDelivery), child: const Text('Out for delivery')),
        ],
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: busy ? null : () => _print(order),
          icon: const Icon(Icons.print_outlined),
          label: const Text('Print receipt'),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
            Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      );
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppConfig.INFO_COLOR.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.circle, size: 10, color: AppConfig.INFO_COLOR),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Status: ${order.status.label}  →  Payment: ${order.paymentStatus.label}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), child],
        ),
      ),
    );
  }
}
