import 'package:flutter/material.dart';

import '../../../../config/app_config.dart';
import '../../../../config/dependency_injection.dart';
import '../../../deliveries/domain/entities/delivery.dart';
import '../../../deliveries/presentation/controllers/delivery_controller.dart';
import '../controllers/location_controller.dart';

/// Live location tracking controls, backed by [LocationController]:
/// start/stop GPS tracking for the active delivery and flush queued
/// location points to the backend.
class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  LocationController get _location => getIt<LocationController>();
  DeliveryController get _deliveries => getIt<DeliveryController>();

  bool _busy = false;

  /// The delivery whose route we track. Prefers the driver's active
  /// delivery (accepted / picked-up / in-transit).
  String? get _activeDeliveryId {
    for (final d in _deliveries.deliveries) {
      if (d.status == DeliveryStatus.accepted ||
          d.status == DeliveryStatus.pickedUp ||
          d.status == DeliveryStatus.inTransit) {
        return d.id;
      }
    }
    return null;
  }

  Future<void> _start() async {
    setState(() => _busy = true);
    await _location.startTracking(deliveryId: _activeDeliveryId);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _stop() async {
    setState(() => _busy = true);
    await _location.stopTracking();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _upload() async {
    setState(() => _busy = true);
    await _location.uploadPending();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final location = _location;
    final tracking = location.isTracking;

    return Scaffold(
      appBar: AppBar(title: const Text('Live Location')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: tracking
                ? AppConfig.SUCCESS_COLOR.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    tracking ? Icons.my_location : Icons.location_off,
                    color: tracking
                        ? AppConfig.SUCCESS_COLOR
                        : Colors.grey,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tracking ? 'Tracking active' : 'Tracking stopped',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (tracking && location.activeDeliveryId.isNotEmpty)
                          Text(
                            'Delivery #${location.activeDeliveryId}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        Text(
                          '${location.pointCount} point(s) queued locally',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (location.error.value.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              color: AppConfig.ERROR_COLOR.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppConfig.ERROR_COLOR),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(location.error.value,
                          style: const TextStyle(
                              color: AppConfig.ERROR_COLOR)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (tracking)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppConfig.ERROR_COLOR,
              ),
              onPressed: _busy ? null : _stop,
              icon: const Icon(Icons.stop),
              label: const Text('Stop tracking'),
            )
          else
            FilledButton.icon(
              onPressed: _busy ? null : _start,
              icon: const Icon(Icons.start),
              label: const Text('Start tracking'),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _upload,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Upload queued points now'),
          ),
          if (!tracking && _activeDeliveryId == null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Tip: accept a delivery first — tracking follows the '
                'active delivery automatically.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
