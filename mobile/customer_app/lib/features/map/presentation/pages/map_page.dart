import 'package:flutter/material.dart';

import '../../../../config/app_config.dart';
import '../../domain/entities/map_location.dart';
import '../widgets/osm_map_widget.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key, this.center, this.markers = const []});

  final MapLocation? center;
  final List<MapLocation> markers;

  @override
  Widget build(BuildContext context) {
    // The active provider is resolved from the white-label config; OSM is the
    // zero-cost default and the widget below is swapped per provider.
    final effectiveCenter =
        center ?? const MapLocation(latitude: 15.3694, longitude: 44.1910); // Sana'a default

    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.6,
              child: OsmMapWidget(center: effectiveCenter, markers: markers),
            ),
            const SizedBox(height: 12),
            Text(
              'Provider: ${AppConfig.DEFAULT_MAP_PROVIDER.name}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
