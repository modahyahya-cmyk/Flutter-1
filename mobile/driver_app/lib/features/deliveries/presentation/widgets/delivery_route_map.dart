import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../../../config/app_config.dart';
import '../../domain/entities/delivery.dart';

/// Shows the pickup -> dropoff route of a [Delivery] on an OpenStreetMap
/// map (flutter_map, zero API key). The straight line is a visual guide —
/// the actual driving distance is reported by the backend as distanceKm.
class DeliveryRouteMap extends StatelessWidget {
  const DeliveryRouteMap({super.key, required this.delivery});

  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    final pickup = ll.LatLng(
      delivery.pickupLocation.latitude,
      delivery.pickupLocation.longitude,
    );
    final dropoff = ll.LatLng(
      delivery.dropoffLocation.latitude,
      delivery.dropoffLocation.longitude,
    );

    return FlutterMap(
      options: MapOptions(
        initialCenter: pickup,
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: AppConfig.OSM_TILE_SERVER,
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.vendorhub.driver',
          attribution: AppConfig.OSM_ATTRIBUTION,
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: [pickup, dropoff],
              strokeWidth: 4,
              color: AppConfig.PRIMARY_COLOR,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: pickup,
              width: 36,
              height: 36,
              child: const Icon(Icons.storefront, color: Colors.blue, size: 36),
            ),
            Marker(
              point: dropoff,
              width: 36,
              height: 36,
              child: const Icon(Icons.home_work, color: Colors.red, size: 36),
            ),
          ],
        ),
      ],
    );
  }
}
