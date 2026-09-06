import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:driver_app/features/deliveries/data/models/delivery_model.dart';
import 'package:driver_app/features/deliveries/domain/entities/delivery.dart';

void main() {
  group('DeliveryModel.fromJson', () {
    test('maps a complete delivery payload correctly', () {
      final delivery = DeliveryModel.fromJson({
        'id': 123,
        'uuid': 'delivery-uuid',
        'order_id': 456,
        'order_number': 'ORD-1001',
        'status': 'assigned',
        'pickup_location': {
          'latitude': 13.5790,
          'longitude': 44.0200,
          'address': 'Pickup Address',
        },
        'dropoff_location': {
          'latitude': '13.5900',
          'longitude': '44.0300',
          'address': 'Dropoff Address',
        },
        'distance_km': '5.5',
        'delivery_fee': 10,
        'driver_earnings': '8.5',
        'platform_commission': 1.5,
        'tip_amount': 2,
        'assigned_at': '2026-01-02T03:04:05Z',
        'vendor': {
          'id': 7,
          'business_name': 'Test Vendor',
          'phone': '123456',
        },
        'customer': {
          'id': 8,
          'name': 'Test Customer',
          'phone': '654321',
        },
        'order': {
          'id': 456,
          'order_number': 'ORD-1001',
          'total_amount': '25.50',
          'payment_method': 'cash',
          'items': [
            {
              'product_name': 'Burger',
              'quantity': 2,
              'price': '12.75',
            },
          ],
        },
      });

      expect(delivery.id, '123');
      expect(delivery.uuid, 'delivery-uuid');
      expect(delivery.orderId, '456');
      expect(delivery.orderNumber, 'ORD-1001');
      expect(delivery.status, DeliveryStatus.assigned);

      expect(delivery.pickupLocation, const LatLng(13.5790, 44.0200));
      expect(delivery.dropoffLocation, const LatLng(13.5900, 44.0300));

      expect(delivery.distanceKm, 5.5);
      expect(delivery.deliveryFee, 10.0);
      expect(delivery.driverEarnings, 8.5);
      expect(delivery.platformCommission, 1.5);
      expect(delivery.tipAmount, 2.0);

      expect(delivery.vendor.id, '7');
      expect(delivery.vendor.businessName, 'Test Vendor');
      expect(delivery.customer.id, '8');
      expect(delivery.customer.name, 'Test Customer');

      expect(delivery.order.totalAmount, 25.5);
      expect(delivery.order.paymentMethod, 'cash');
      expect(delivery.order.items, hasLength(1));
      expect(delivery.order.items.first.productName, 'Burger');
      expect(delivery.order.items.first.quantity, 2);
      expect(delivery.order.items.first.price, 12.75);
    });

    test('uses defensive defaults for missing nested payloads', () {
      final delivery = DeliveryModel.fromJson({
        'id': 1,
        'status': 'accepted',
      });

      expect(delivery.id, '1');
      expect(delivery.uuid, '1');
      expect(delivery.orderId, 'null');
      expect(delivery.orderNumber, 'N/A');
      expect(delivery.status, DeliveryStatus.accepted);

      expect(delivery.pickupLocation, const LatLng(0, 0));
      expect(delivery.dropoffLocation, const LatLng(0, 0));
      expect(delivery.vendor.businessName, 'Vendor');
      expect(delivery.customer.name, 'Customer');
      expect(delivery.order.items, isEmpty);
    });
  });
}
