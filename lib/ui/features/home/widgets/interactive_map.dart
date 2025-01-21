import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cached_tile_provider/flutter_map_cached_tile_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:where_im_at/app/themes/app_assets.dart';
import 'package:where_im_at/config/dependency_injection/di_keys.dart';
import 'package:where_im_at/config/environment/env.dart';
import 'package:where_im_at/domain/models/user_location.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';

class InteractiveMap extends StatefulWidget {
  const InteractiveMap({
    required this.userLocations,
    this.initialLocation,
    super.key,
  });

  final List<UserLocation> userLocations;
  final LatLng? initialLocation;

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  late final _mapController = MapController();
  late final _stadiaMapsApiKey = GetIt.I<Env>().stadiaMapsApiKey;
  late final _mapCacheManager =
      GetIt.I<CacheManager>(instanceName: DiKeys.mapCacheManager);

  @override
  void didUpdateWidget(InteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLocation != null &&
        widget.initialLocation != oldWidget.initialLocation) {
      _mapController.move(widget.initialLocation!, 12.0);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _mapCacheManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
        initialCenter: LatLng(12.8797, 121.7740), // Philippines
        initialZoom: 6,
      ),
      children: [
        _buildMapLayer(),
        _buildUserLocationMarkers(),
        _buildAttributionButton(),
      ],
    );
  }

  Widget _buildMapLayer() {
    return TileLayer(
      // TODO Handle dark theme (alidade_smooth_dark)
      urlTemplate:
          'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key={api_key}',
      tileProvider: CachedTileProvider(cacheManager: _mapCacheManager),
      additionalOptions: {'api_key': _stadiaMapsApiKey},
      retinaMode: RetinaMode.isHighDensity(context),
    );
  }

  Widget _buildUserLocationMarkers() {
    return MarkerLayer(
      markers: widget.userLocations
          .map(
            (location) => Marker(
              point: location.latLong,
              child: SvgPicture.asset(AppAssets.mainLogo, height: 42),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAttributionButton() {
    return Positioned(
      left: 0,
      top: 0,
      child: SafeArea(
        child: IconButton(
          icon: Icon(
            Icons.location_on_outlined,
            color: context.colorScheme.primary.withAlpha(120),
          ),
          onPressed: _showAttributionBottomSheet,
        ),
      ),
    );
  }

  Future<void> _showAttributionBottomSheet() async {
    final result = await showModalActionSheet<String>(
      context: context,
      cancelLabel: context.l10n.close,
      title: context.l10n.mapAttributions,
      actions: [
        SheetAction(
          label: '© ${context.l10n.stadiaMaps}',
          key: 'stadia',
        ),
        SheetAction(
          label: '© ${context.l10n.openStreetMapContributors}',
          key: 'osm',
        ),
        SheetAction(
          label: '© ${context.l10n.openMapTiles}',
          key: 'omt',
        ),
      ],
    );

    if (result != null) {
      launchUrlString(
        switch (result) {
          'stadia' => 'https://stadiamaps.com/',
          'osm' => 'https://www.openstreetmap.org/copyright',
          'omt' => 'https://openmaptiles.org/',
          _ => throw ArgumentError('Unknown url: $result'),
        },
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
