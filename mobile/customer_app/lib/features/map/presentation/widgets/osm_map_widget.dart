import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../config/app_config.dart';
import '../../domain/entities/map_location.dart';

/// Interactive OpenStreetMap view rendered with [FlutterMap].
///
/// Tiles come straight from the OSM tile servers configured in the
/// white-label config (zero API key / zero cost). Markers are drawn with
/// a [MarkerLayer]; the center defaults to the platform default location
/// when none is supplied.
class OsmMapWidget extends StatelessWidget {
  const OsmMapWidget({
    super.key,
    this.center,
    this.markers = const [],
    this.zoom = 14,
  });

  final MapLocation? center;
  final List<MapLocation> markers;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final location = center ?? const MapLocation(
      latitude: 15.3694, // Sana'a default
      longitude: 44.1910,
    );

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(location.latitude, location.longitude),
        initialZoom: zoom,
      ),
      children: [
        TileLayer(
          urlTemplate: AppConfig.OSM_TILE_SERVER,
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: AppConfig.ANDROID_PACKAGE_NAME,
          attribution: AppConfig.OSM_ATTRIBUTION,
        ),
        // No explicit center supplied: show the default location as a marker.
        if (center == null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(location.latitude, location.longitude),
                width: 32,
                height: 32,
                child: const Icon(Icons.map, color: Colors.blue, size: 32),
              ),
            ],
          ),
        if (markers.isNotEmpty)
          MarkerLayer(
            markers: [
              for (final marker in markers)
                Marker(
                  point: LatLng(marker.latitude, marker.longitude),
                  width: 32,
                  height: 32,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.place, color: Colors.red, size: 28),
                      if (marker.label != null)
                        Text(
                          marker.label!,
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
