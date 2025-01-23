part of 'home_screen_cubit.dart';

sealed class HomeScreenState {
  const HomeScreenState();
}

final class HomeScreenInitial extends HomeScreenState {
  const HomeScreenInitial();
}

final class HomeScreenLoading extends HomeScreenState {
  const HomeScreenLoading();
}

final class HomeScreenShouldRedirectToSetUpProfile extends HomeScreenState {
  const HomeScreenShouldRedirectToSetUpProfile();
}

final class HomeScreenError extends HomeScreenState {
  const HomeScreenError(this.errorMessage);

  final String errorMessage;
}

@MappableClass()
final class HomeScreenLoaded extends HomeScreenState
    with HomeScreenLoadedMappable {
  const HomeScreenLoaded({
    required this.isBroadcastingLocation,
    required this.userLocations,
    required this.initialLocation,
  });

  final bool isBroadcastingLocation;
  final List<UserLocation> userLocations;
  final LatLng initialLocation;
}
