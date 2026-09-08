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
    // OSM is the zero-cost default provider from the white-label config.
    final provider = AppConfig.DEFAULT_MAP_PROVIDER;

    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: Stack(
        children: [
          Positioned.fill(
            child: OsmMapWidget(center: center, markers: markers, zoom: 13),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Provider: ${provider.name}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
