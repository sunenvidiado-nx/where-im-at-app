import 'dart:io';
import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:where_im_at/config/dependency_injection/di_keys.dart';
import 'package:where_im_at/config/environment/env.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';

class InteractiveMap extends StatefulWidget {
  const InteractiveMap({this.initialLocation, super.key});

  final LatLng? initialLocation;

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  late final _mapController = MapController(
    zoom: 6,
    location: widget.initialLocation ??
        LatLng.degree(12.8797, 121.7740), // Philippines
  );

  late final _mapCacheManager =
      GetIt.I<CacheManager>(instanceName: DiKeys.mapCacheManager);

  MapTransformer? _mapTransformer;
  Offset? _dragStart;
  double _scaleStart = 1.0;

  // Zooming in android is too fast, so we need to slow it down
  final _zoomFactor = Platform.isAndroid ? 0.02 : 0.04;

  void _onScaleStart(ScaleStartDetails details) {
    setState(() {
      _dragStart = details.focalPoint;
      _scaleStart = 1.0;
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final scaleDiff = details.scale - _scaleStart;

    if (scaleDiff > 0) {
      _mapController.zoom += _zoomFactor;
    } else if (scaleDiff < 0) {
      _mapController.zoom -= _zoomFactor;
    } else {
      final now = details.focalPoint;
      final diff = now - _dragStart!;
      _mapTransformer?.drag(diff.dx, diff.dy);
    }

    setState(() {
      _scaleStart = details.scale;
      _dragStart = details.focalPoint;
    });
  }

  void _zoomListener(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final delta = event.scrollDelta.dy / -1000.0;
      final zoom = _mapController.zoom + delta.clamp(2, 18);
      _mapTransformer?.setZoomInPlace(zoom, event.localPosition);
    }
  }

  String _stadiaMapUrl(num z, int x, int y) {
    const mapTheme =
        'alidade_smooth'; // TODO Add dark theme (alidade_smooth_dark)
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final apiKey = GetIt.I<Env>().stadiaMapsApiKey;
    return 'https://tiles.stadiamaps.com/tiles/$mapTheme/$z/$x/$y${devicePixelRatio >= 2 ? '@2x' : ''}.png?api_key=$apiKey';
  }

  (int x, int y, num z) _normalizeTileCoordinates(int x, int y, int z) {
    final tilesInZoom = pow(2.0, z).floor();

    while (x < 0) {
      x += tilesInZoom;
    }
    while (y < 0) {
      y += tilesInZoom;
    }

    while (x >= tilesInZoom) {
      x -= tilesInZoom;
    }
    while (y >= tilesInZoom) {
      y -= tilesInZoom;
    }

    return (x, y, z);
  }

  Widget _buildMapTile(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      cacheManager: _mapCacheManager,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) =>
          const ColoredBox(color: Colors.grey),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 3));
      _mapTransformer?.setZoomInPlace(_mapController.zoom + 3, Offset.zero);
    });
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
        _mapTransformer ??= transformer;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerSignal: _zoomListener,
            child: Stack(
              children: [
                TileLayer(
                  builder: (context, x, y, z) {
                    final (nX, nY, nZ) = _normalizeTileCoordinates(x, y, z);
                    return _buildMapTile(_stadiaMapUrl(nZ, nX, nY));
                  },
                ),
                Positioned(
                  left: 2,
                  child: SafeArea(
                    child: Transform.scale(
                      scale: 0.8,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withAlpha(140),
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(
                          Icons.info_outline,
                          color: Colors.black87,
                        ),
                        onPressed: _showAttributionBottomSheet,
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
}
