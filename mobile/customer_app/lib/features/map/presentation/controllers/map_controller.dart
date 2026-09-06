import 'package:flutter/foundation.dart';

import '../../../../config/app_config.dart';

/// Handles map intent / provider selection and exposes the active provider to
/// the widget layer. Named *ProviderController* to avoid shadowing
/// flutter_map's `MapController`. The [MapProvider] is resolved from the
/// white-label config.
class MapProviderController extends ChangeNotifier {
  MapProviderController();

  MapProvider _provider = AppConfig.DEFAULT_MAP_PROVIDER;

  MapProvider get provider => _provider;

  void setProvider(MapProvider provider) {
    _provider = provider;
    notifyListeners();
  }

  bool get activeProviderEnabled => _provider.isEnabled;

  String get tileServer => switch (_provider) {
        MapProvider.OPENSTREETMAP => AppConfig.OSM_TILE_SERVER,
        _ => '',
      };
}
