part of 'interactive_map_state_manager.dart';

@MappableClass()
class InteractiveMapState with InteractiveMapStateMappable {
  const InteractiveMapState({
    required this.pathPoints,
    this.initialLocation,
    this.dragStart,
    this.scaleStart = 1.0,
  });

  factory InteractiveMapState.initial() => InteractiveMapState(
        pathPoints: [],
        initialLocation: LatLng.degree(12.8797, 121.7740), // Philippines
      );

  final List<LatLng> pathPoints;
  final LatLng? initialLocation;
  final Offset? dragStart;
  final double scaleStart;
}
