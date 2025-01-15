import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:map/map.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';
import 'package:where_im_at/config/dependency_injection/di_keys.dart';
import 'package:where_im_at/ui/features/home/interactive_map/interactive_map_state_manager.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';
import 'package:where_im_at/utils/extensions/int_extensions.dart';

class InteractiveMap extends ManagedStatefulWidget<InteractiveMapStateManager,
    InteractiveMapState> {
  const InteractiveMap({super.key});

  @override
  InteractiveMapStateManager createStateManager() => GetIt.I();

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends ManagedState<InteractiveMapStateManager,
    InteractiveMapState, InteractiveMap> {
  late final _mapController =
      MapController(location: state.initialLocation!, zoom: 8);
  late final _mapCacheManager =
      GetIt.I<CacheManager>(instanceName: DiKeys.mapCacheManager);

  @override
  void initState() {
    super.initState();
    stateManager.initialize();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _mapCacheManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapLayout(
      controller: _mapController,
      builder: (context, transformer) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTapDown: (details) => stateManager.onDoubleTap(
            transformer,
            details.localPosition,
            _mapController,
          ),
          onScaleStart: stateManager.onScaleStart,
          onScaleUpdate: (details) => stateManager.onScaleUpdate(
            details,
            transformer,
            _mapController,
          ),
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerSignal: (event) => stateManager.zoomListener(
              event,
              transformer,
              _mapController,
            ),
            child: Stack(
              children: [
                TileLayer(
                  builder: (context, x, y, z) {
                    final (nX, nY, nZ) =
                        stateManager.normalizeTileCoordinates(x, y, z);
                    final r = MediaQuery.of(context).devicePixelRatio;

                    return _buildMapTile(
                      context,
                      stateManager.stadiaMapUrl(r, nZ, nX, nY),
                    );
                  },
                ),
                Positioned(
                  left: 2,
                  child: SafeArea(
                    child: Transform.scale(
                      scale: 0.75,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withAlpha(140),
                          padding: EdgeInsets.zero,
                        ),
                        icon: Icon(
                          Icons.info_outline,
                          color: Colors.grey.withAlpha(200),
                        ),
                        onPressed: () => _showAttributionBottomSheet(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapTile(BuildContext context, String mapUrl) {
    return CachedNetworkImage(
      imageUrl: mapUrl,
      cacheManager: _mapCacheManager,
      fadeInDuration: Duration.zero,
      fadeOutDuration: 600.milliseconds,
      fadeOutCurve: Curves.easeInCirc,
      errorWidget: (context, url, error) => ColoredBox(
        color: Theme.of(context).colorScheme.surface,
      ),
      placeholder: (context, url) => ColoredBox(
        color: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Future<void> _showAttributionBottomSheet(BuildContext context) async {
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
