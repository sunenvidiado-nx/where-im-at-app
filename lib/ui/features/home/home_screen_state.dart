part of 'home_screen_cubit.dart';

@MappableClass()
class HomeScreenState with HomeScreenStateMappable {
  const HomeScreenState({
    this.isBroadcastingLocation = false,
    this.shouldSetUpProfile = false,
    this.userLocations = const [],
    this.initialLocation,
    this.exception,
  });

  final bool isBroadcastingLocation;
  final bool shouldSetUpProfile;
  final List<UserLocation> userLocations;
  final LatLng? initialLocation;
  final Object? exception;
}
