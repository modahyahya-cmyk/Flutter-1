/// A geographic point (lat/lng) plus an optional label used by map widgets.
class MapLocation {
  const MapLocation({
    required this.latitude,
    required this.longitude,
    this.label,
  });

  final double latitude;
  final double longitude;
  final String? label;
}
