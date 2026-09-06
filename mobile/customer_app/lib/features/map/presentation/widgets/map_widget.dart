import 'package:flutter/widgets.dart';

import '../../domain/entities/map_location.dart';

/// Abstract map interface. Concrete provider widgets (OSM / Google / Mapbox)
/// implement this so the app is hot-swappable at the white-label level.
abstract class MapWidget extends StatelessWidget {
  const MapWidget({super.key, required this.center, this.markers = const []});

  final MapLocation center;
  final List<MapLocation> markers;
}
