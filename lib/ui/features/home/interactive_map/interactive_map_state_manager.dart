import 'dart:io';
import 'dart:math';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/gestures.dart';
import 'package:injectable/injectable.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';
import 'package:where_im_at/config/environment/env.dart';
import 'package:where_im_at/data/services/location_service.dart';

part 'interactive_map_state.dart';
part 'interactive_map_state_manager.mapper.dart';

@injectable
class InteractiveMapStateManager extends StateManager<InteractiveMapState> {
  InteractiveMapStateManager(
    this._locationService,
    this._environment,
  ) : super(InteractiveMapState.initial());

  final LocationService _locationService;
  final Env _environment;

  late final _zoomFactor = Platform.isAndroid ? 0.02 : 0.04;

  Future<void> initialize() async {
    state = state.copyWith(
      initialLocation: await _locationService.getCurrentLocation(),
    );
  }

  void onScaleStart(ScaleStartDetails details) {
    state = state.copyWith(
      dragStart: details.focalPoint,
      scaleStart: 1.0,
    );
  }

  void onDoubleTap(
    MapTransformer transformer,
    Offset position,
    MapController mapController,
  ) {
    const delta = 0.5;
    final zoom = mapController.zoom + delta.clamp(2, 18);
    transformer.setZoomInPlace(zoom, position);
  }

  void onScaleUpdate(
    ScaleUpdateDetails details,
    MapTransformer transformer,
    MapController mapController,
  ) {
    final scaleDiff = details.scale - state.scaleStart;

    if (scaleDiff > 0) {
      mapController.zoom += _zoomFactor;
    } else if (scaleDiff < 0) {
      mapController.zoom -= _zoomFactor;
    } else {
      final now = details.focalPoint;
      final diff = now - state.dragStart!;
      transformer.drag(diff.dx, diff.dy);
    }

    state = state.copyWith(
      scaleStart: details.scale,
      dragStart: details.focalPoint,
    );
  }

  String stadiaMapUrl(num devicePixelRatio, num z, int x, int y) {
    final mapTheme = 'alidade_smooth'; // Add light theme (alidade_smooth_dark)
    final apiKey = _environment.stadiaMapsApiKey;
    return 'https://tiles.stadiamaps.com/tiles/$mapTheme/$z/$x/$y${devicePixelRatio > 2 ? '@2x' : ''}.png?api_key=$apiKey';
  }

  void zoomListener(
    PointerSignalEvent event,
    MapTransformer transformer,
    MapController mapController,
  ) {
    if (event is PointerScrollEvent) {
      final delta = event.scrollDelta.dy / -1000.0;
      final zoom = mapController.zoom + delta.clamp(2, 18);
      transformer.setZoomInPlace(zoom, event.localPosition);
    }
  }

  (int x, int y, num z) normalizeTileCoordinates(int x, int y, int z) {
    final tilesInZoom = pow(2.0, z).floor();

    while (x < 0) {
      x += tilesInZoom;
    }

    while (y < 0) {
      y += tilesInZoom;
    }

    x %= tilesInZoom;
    y %= tilesInZoom;

    return (x, y, z);
  }
}
