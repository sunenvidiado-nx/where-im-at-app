part of 'home_screen_cubit.dart';

@MappableClass()
class HomeScreenState with HomeScreenStateMappable {
  const HomeScreenState({
    this.isLoading = false,
    this.shouldRedirectToSetUpProfile = false,
    this.errorMessage,
    this.isBroadcastingLocation = false,
    this.userLocations = const [],
    this.initialLocation,
    this.userToUserRoute,
    this.userIdToNavigateTo,
  });

  final bool isLoading;
  final bool shouldRedirectToSetUpProfile;
  final String? errorMessage;
  final bool isBroadcastingLocation;
  final List<UserLocation> userLocations;
  final LatLng? initialLocation;
  final List<LatLng>? userToUserRoute;
  final String? userIdToNavigateTo;

  bool get hasError => errorMessage != null;
  bool get isLoaded => !isLoading && !shouldRedirectToSetUpProfile && !hasError;
}
