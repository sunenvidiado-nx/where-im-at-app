import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_cached_tile_provider/flutter_map_cached_tile_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:where_im_at/config/dependency_injection/di_keys.dart';
import 'package:where_im_at/config/environment/env.dart';
import 'package:where_im_at/domain/models/user_location.dart';
import 'package:where_im_at/ui/features/home/home_screen_cubit.dart';
import 'package:where_im_at/ui/features/home/widgets/user_marker.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';
import 'package:where_im_at/utils/extensions/int_extensions.dart';

class InteractiveMap extends StatefulWidget {
  const InteractiveMap({
    required this.userLocations,
    this.userToUserRoute,
    this.initialLocation,
    super.key,
  });

  final List<UserLocation> userLocations;
  final List<LatLng>? userToUserRoute;
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
      _mapController.move(widget.initialLocation!, 12);
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
        maxZoom: 18,
        initialCenter: LatLng(12.8797, 121.7740), // Philippines
        initialZoom: 6,
      ),
      children: [
        _buildMapLayer(),
        _buildPolylines(),
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
    final cubit = context.read<HomeScreenCubit>();
    return AnimatedMarkerLayer(
      markers: List.generate(
        widget.userLocations.length,
        (index) => AnimatedMarker(
          key: Key(widget.userLocations[index].id!),
          point: widget.userLocations[index].latLong,
          duration: 150.milliseconds,
          // TODO I just eyeballed these, there's prolly a better way to do it
          width: 100,
          height: 80,
          alignment: Alignment.topCenter,
          builder: (_, animation) => UserMarker(
            animation: animation,
            userId: widget.userLocations[index].id!,
            isNavigatingToThisMarker:
                cubit.isNavigatingToUser(widget.userLocations[index].id!),
            currentUserIsNavigating: cubit.isCurrentlyNavigating(),
          ),
        ),
      ),
    );
  }

  Widget _buildPolylines() {
    return PolylineLayer(
      polylines: [
        if (widget.userToUserRoute != null)
          Polyline(
            points: widget.userToUserRoute!,
            color: context.colorScheme.primary,
            strokeWidth: 4,
          ),
      ],
    );
  }

  Widget _buildAttributionButton() {
    return Positioned(
      left: 0,
      top: 0,
      child: SafeArea(
        child: IconButton(
          icon: Icon(
            Icons.info_outline_rounded,
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
      cancelLabel: context.l10n.mapAttributionsDissmisButton,
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
      launchUrl(
        Uri.parse(
          switch (result) {
            'stadia' => 'https://stadiamaps.com/',
            'osm' => 'https://www.openstreetmap.org/copyright',
            'omt' => 'https://openmaptiles.org/',
            _ => throw ArgumentError('Unknown url: $result'),
          },
        ),
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
