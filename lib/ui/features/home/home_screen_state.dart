part of 'home_screen_state_manager.dart';

@MappableClass()
class HomeScreenState with HomeScreenStateMappable {
  const HomeScreenState({
    this.isBroadcastingLocation = false,
    this.userLocations = const [],
    this.initialLocation,
    this.exception,
  });

  final bool isBroadcastingLocation;
  final List<UserLocation> userLocations;
  final LatLng? initialLocation;
  final Object? exception;
}
