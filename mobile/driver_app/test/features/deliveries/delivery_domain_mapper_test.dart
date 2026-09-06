import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:driver_app/features/deliveries/data/mappers/delivery_mapper.dart';
import 'package:driver_app/features/deliveries/data/models/delivery_model.dart';
import 'package:driver_app/features/deliveries/domain/entities/delivery.dart';

void main() {
  Delivery createDelivery() {
    return Delivery(
      id: 'delivery-1',
      uuid: 'uuid-1',
      orderId: 'order-1',
      orderNumber: 'ORD-1',
      status: DeliveryStatus.accepted,
      pickupLocation: const LatLng(13.57, 44.02),
      pickupAddress: 'Pickup',
      dropoffLocation: const LatLng(13.59, 44.03),
      dropoffAddress: 'Dropoff',
      distanceKm: 5.5,
      deliveryFee: 10,
      driverEarnings: 8,
      platformCommission: 2,
      tipAmount: 1.5,
      assignedAt: DateTime.utc(2026, 1, 1),
      acceptedAt: DateTime.utc(2026, 1, 2),
      vendor: const VendorSnapshot(
        id: 'vendor-1',
        businessName: 'Vendor',
      ),
      customer: const CustomerSnapshot(
        id: 'customer-1',
        name: 'Customer',
        phone: '123',
      ),
      order: const OrderSnapshot(
        id: 'order-1',
        orderNumber: 'ORD-1',
        totalAmount: 25,
        paymentMethod: 'cash',
        items: [
          OrderItemSnapshot(
            productName: 'Burger',
            quantity: 2,
            price: 12.5,
          ),
        ],
      ),
    );
  }

  group('Delivery.copyWith', () {
    test('changes requested fields while preserving immutable data', () {
      final original = createDelivery();
      final updated = original.copyWith(
        status: DeliveryStatus.pickedUp,
        pickedUpAt: DateTime.utc(2026, 1, 3),
      );

      expect(updated.status, DeliveryStatus.pickedUp);
      expect(updated.pickedUpAt, DateTime.utc(2026, 1, 3));
      expect(updated.id, original.id);
      expect(updated.orderId, original.orderId);
      expect(updated.vendor, original.vendor);
      expect(updated.customer, original.customer);
      expect(updated.order, original.order);
    });

    test('preserves nullable fields when not supplied', () {
      final original = createDelivery();

      final updated = original.copyWith(
        status: DeliveryStatus.inTransit,
      );

      expect(updated.acceptedAt, original.acceptedAt);
      expect(updated.pickedUpAt, original.pickedUpAt);
      expect(updated.deliveryProofImage, original.deliveryProofImage);
      expect(updated.failureReason, original.failureReason);
    });
  });

  group('DeliveryMapper', () {
    test('maps domain delivery to local model with sync flags', () {
      final delivery = createDelivery();

      final local = DeliveryMapper.toLocal(
        delivery,
        needsSync: true,
        isOfflineCreated: true,
      );

      expect(local.deliveryId, delivery.id);
      expect(local.orderId, delivery.orderId);
      expect(local.orderNumber, delivery.orderNumber);
      expect(local.vendorName, delivery.vendor.businessName);
      expect(local.customerName, delivery.customer.name);
      expect(local.status, delivery.status.wire);
      expect(local.pickupLatitude, delivery.pickupLocation.latitude);
      expect(local.pickupLongitude, delivery.pickupLocation.longitude);
      expect(local.dropoffLatitude, delivery.dropoffLocation.latitude);
      expect(local.dropoffLongitude, delivery.dropoffLocation.longitude);
      expect(local.needsSync, isTrue);
      expect(local.isOfflineCreated, isTrue);
    });

    test('maps local model back to domain without losing core delivery state', () {
      final original = createDelivery();
      final local = DeliveryMapper.toLocal(original);

      final restored = DeliveryMapper.fromLocal(local);

      expect(restored.id, original.id);
      expect(restored.orderId, original.orderId);
      expect(restored.orderNumber, original.orderNumber);
      expect(restored.status, original.status);
      expect(restored.pickupLocation, original.pickupLocation);
      expect(restored.dropoffLocation, original.dropoffLocation);
      expect(restored.distanceKm, original.distanceKm);
      expect(restored.deliveryFee, original.deliveryFee);
      expect(restored.driverEarnings, original.driverEarnings);
      expect(restored.tipAmount, original.tipAmount);
      expect(restored.vendor.businessName, original.vendor.businessName);
      expect(restored.customer.name, original.customer.name);
    });
  });

  test('DeliveryModel remains a Delivery domain subtype', () {
    final model = DeliveryModel.fromJson({
      'id': 1,
      'status': 'assigned',
    });

    expect(model, isA<Delivery>());
  });
}
