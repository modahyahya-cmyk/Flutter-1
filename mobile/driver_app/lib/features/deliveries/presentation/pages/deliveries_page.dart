import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/app_config.dart';
import '../../../../config/dependency_injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/delivery.dart';
import '../controllers/delivery_controller.dart';

/// The driver's live delivery queue.
///
/// Backed by [DeliveryController] (remote API + offline Isar cache), split
/// into three sections: the in-progress delivery, claimable deliveries, and
/// recently completed ones. Tapping a row opens the delivery detail page
/// with the accept / pickup / complete actions and the route map.
class DeliveriesPage extends StatelessWidget {
  const DeliveriesPage({super.key});

  DeliveryController get _controller => getIt<DeliveryController>();

  void _openDetail(BuildContext context, Delivery d) {
    Get.toNamed('${AppRoutes.deliveryDetail}/${d.id}');
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Obx(() {
      final deliveries = controller.deliveries;

      if (controller.isLoading.value && deliveries.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (deliveries.isEmpty && controller.error.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  controller.error.value,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => controller.loadDeliveries(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      final active = deliveries
          .where((d) =>
              d.status == DeliveryStatus.accepted ||
              d.status == DeliveryStatus.pickedUp ||
              d.status == DeliveryStatus.inTransit)
          .toList();
      final available = controller.availableDeliveries;
      final completed = controller.completedDeliveries;

      return RefreshIndicator(
        onRefresh: () => controller.loadDeliveries(refresh: true),
        child: ListView(
          padding: const EdgeInsets.all(12),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (active.isNotEmpty) ...[
              _SectionHeader(title: 'Active'),
              for (final d in active)
                _DeliveryTile(
                  delivery: d,
                  color: AppConfig.PRIMARY_COLOR,
                  onTap: () => _openDetail(context, d),
                ),
            ],
            if (available.isNotEmpty) ...[
              _SectionHeader(title: 'Available near you'),
              for (final d in available)
                _DeliveryTile(
                  delivery: d,
                  color: AppConfig.SUCCESS_COLOR,
                  trailing: FilledButton.tonal(
                    onPressed: () => controller.acceptDelivery(d.id),
                    child: const Text('Accept'),
                  ),
                  onTap: () => _openDetail(context, d),
                ),
            ],
            if (completed.isNotEmpty) ...[
              _SectionHeader(title: 'Completed'),
              for (final d in completed.take(10))
                _DeliveryTile(
                  delivery: d,
                  color: Colors.grey,
                  onTap: () => _openDetail(context, d),
                ),
            ],
            if (deliveries.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('No deliveries right now.\nCheck back soon.'),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _DeliveryTile extends StatelessWidget {
  const _DeliveryTile({
    required this.delivery,
    required this.color,
    this.trailing,
    required this.onTap,
  });

  final Delivery delivery;
  final Color color;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.delivery_dining, color: color),
        title: Text(
          '#${delivery.orderNumber} — ${delivery.customerName}',
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${delivery.status.label}'
          '${delivery.distanceKm > 0 ? ' · ${delivery.distanceKm.toStringAsFixed(1)} km' : ''}'
          ' · +${AppConfig.formatCurrency(delivery.totalEarnings)}',
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}
