import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/app_config.dart';
import '../../../../config/dependency_injection.dart';
import '../../../location_tracking/presentation/controllers/location_controller.dart';
import '../../domain/entities/delivery.dart';
import '../controllers/delivery_controller.dart';

class DeliveryDetailPage extends StatelessWidget {
  DeliveryDetailPage({super.key, required this.deliveryId});

  final String deliveryId;

  DeliveryController get _controller => getIt<DeliveryController>();
  LocationController get _location => getIt<LocationController>();

  Future<void> _complete(BuildContext context, Delivery d) async {
    final proofImage = await _controller.captureProofOfDelivery();
    final notesController = TextEditingController();
    final notes = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete delivery'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(labelText: 'Notes (optional)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, notesController.text.trim()), child: const Text('Confirm delivery')),
        ],
      ),
    );
    if (notes == null) return;
    await _controller.completeDelivery(
      deliveryId: d.id,
      proofImage: proofImage,
      notes: notes.isEmpty ? null : notes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery')),
      body: Obx(() {
        final delivery = controller.getDeliveryById(deliveryId);
        if (delivery == null) {
          return const Center(child: Text('Delivery not found'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: AppConfig.INFO_COLOR.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.delivery_dining),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '#${delivery.orderNumber} — ${delivery.status.label}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Pickup',
              children: [
                _row('Vendor', delivery.vendorName),
                if (delivery.vendorPhone != null) _row('Phone', delivery.vendorPhone!),
                _row('Address', delivery.pickupAddress),
              ],
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Dropoff',
              children: [
                _row('Customer', delivery.customerName),
                if (delivery.customerPhone != null) _row('Phone', delivery.customerPhone!),
                _row('Address', delivery.dropoffAddress),
              ],
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Order',
              children: [
                for (final item in delivery.items) _row('${item.quantity}× ${item.productName}', AppConfig.formatCurrency(item.price)),
                const Divider(),
                _row('Order total', AppConfig.formatCurrency(delivery.orderTotal)),
                _row('Your earnings', '+${AppConfig.formatCurrency(delivery.totalEarnings)}', color: AppConfig.SUCCESS_COLOR),
              ],
            ),
            const SizedBox(height: 16),
            _actions(context, delivery),
          ],
        );
      }),
    );
  }

  Widget _actions(BuildContext context, Delivery d) {
    if (d.canAccept) {
      return FilledButton(onPressed: () => _controller.acceptDelivery(d.id), child: const Text('Accept delivery'));
    }
    if (d.canPickup) {
      return Column(
        children: [
          FilledButton(onPressed: () => _controller.markAsPickedUp(d.id), child: const Text('Mark as picked up')),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              _location.startTracking(deliveryId: d.id);
              _controller.markAsInTransit(d.id);
            },
            icon: const Icon(Icons.map_outlined),
            label: const Text('Start delivery & track'),
          ),
        ],
      );
    }
    if (d.canComplete) {
      return FilledButton(onPressed: () => _complete(context, d), child: const Text('Complete delivery'));
    }
    return const SizedBox.shrink();
  }

  Widget _row(String label, String value, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: TextStyle(color: Colors.grey.shade600))),
            const SizedBox(width: 12),
            Expanded(child: Text(value, textAlign: TextAlign.end, style: TextStyle(color: color))),
          ],
        ),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}
