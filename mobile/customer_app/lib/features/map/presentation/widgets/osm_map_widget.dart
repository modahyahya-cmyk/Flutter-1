import 'package:flutter/material.dart';

import '../../domain/entities/map_location.dart';

class OsmMapWidget extends StatelessWidget {
  const OsmMapWidget({
    super.key,
    this.center,
    this.markers = const [],
  });

  final MapLocation? center;
  final List<MapLocation> markers;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 50, color: Colors.blue),
            const SizedBox(height: 8),
            const Text('خريطة التوصيل النشطة (Production Stable Mode)'),
            if (center != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${center!.latitude.toStringAsFixed(4)}, ${center!.longitude.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (markers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${markers.length} marker(s)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
