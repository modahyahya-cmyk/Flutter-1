import 'package:flutter_test/flutter_test.dart';

import 'package:driver_app/core/storage/models/delivery_local_model.dart';

void main() {
  DeliveryLocalModel createModel() {
    return DeliveryLocalModel(
      deliveryId: 'delivery-1',
      orderId: 'order-1',
      orderNumber: 'ORD-1',
      vendorName: 'Vendor',
      customerName: 'Customer',
      customerPhone: '123',
      status: 'accepted',
      pickupLatitude: 13.57,
      pickupLongitude: 44.02,
      pickupAddress: 'Pickup',
      dropoffLatitude: 13.59,
      dropoffLongitude: 44.03,
      dropoffAddress: 'Dropoff',
      distanceKm: 5.5,
      deliveryFee: 10,
      driverEarnings: 8,
      platformCommission: 2,
      tipAmount: 1.5,
      assignedAt: DateTime.utc(2026, 1, 1),
      acceptedAt: DateTime.utc(2026, 1, 2),
      needsSync: false,
      isOfflineCreated: false,
    );
  }

  test('creates a local delivery with expected defaults', () {
    final model = createModel();

    expect(model.deliveryId, 'delivery-1');
    expect(model.status, 'accepted');
    expect(model.needsSync, isFalse);
    expect(model.isOfflineCreated, isFalse);
    expect(model.localUpdatedAt, isNotNull);
  });

  test('copyWith changes sync state and status without losing data', () {
    final model = createModel();

    final updated = model.copyWith(
      status: 'picked_up',
      needsSync: true,
      pickedUpAt: DateTime.utc(2026, 1, 3),
    );

    expect(updated.deliveryId, model.deliveryId);
    expect(updated.orderId, model.orderId);
    expect(updated.customerPhone, model.customerPhone);
    expect(updated.status, 'picked_up');
    expect(updated.needsSync, isTrue);
    expect(updated.pickedUpAt, DateTime.utc(2026, 1, 3));
    expect(updated.isOfflineCreated, model.isOfflineCreated);
    expect(updated.localUpdatedAt, isNotNull);
  });

  test('copyWith preserves nullable fields when omitted', () {
    final model = createModel();

    final updated = model.copyWith(status: 'in_transit');

    expect(updated.acceptedAt, model.acceptedAt);
    expect(updated.pickedUpAt, model.pickedUpAt);
    expect(updated.deliveryProofImage, model.deliveryProofImage);
    expect(updated.failureReason, model.failureReason);
    expect(updated.needsSync, model.needsSync);
  });
}
