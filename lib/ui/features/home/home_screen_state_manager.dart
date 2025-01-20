import 'dart:async';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';
import 'package:where_im_at/data/repositories/user_location_repository.dart';
import 'package:where_im_at/data/services/auth_service.dart';
import 'package:where_im_at/data/services/location_service.dart';
import 'package:where_im_at/domain/models/user_location.dart';

part 'home_screen_state.dart';
part 'home_screen_state_manager.mapper.dart';

@injectable
class HomeScreenStateManager extends StateManager<HomeScreenState> {
  HomeScreenStateManager(
    this._authService,
    this._locationService,
    this._userLocationRepository,
  ) : super(const HomeScreenState());

  final AuthService _authService;
  final LocationService _locationService;
  final UserLocationRepository _userLocationRepository;

  late Stream<Position> _currentLocationStream;
  late Stream<List<UserLocation>> _userLocationsStream;

  /// Used to handle updates from current user's location.
  StreamSubscription<Position>? _locationSubscription;

  /// Used to handle updates from other users' locations.
  StreamSubscription<List<UserLocation>>? _userLocationsSubscription;

  /// Current user ID that will be used to set the IDs of
  /// other data related to the current user.
  String get _userId => _authService.currentUser!.uid;

  Future<void> initialize() async {
    try {
      _userLocationsStream = _userLocationRepository.streamUserLocations();
      _userLocationsSubscription = _userLocationsStream.listen(
        (userLocations) {
          final updatedLocations = [...state.userLocations, ...userLocations]
              .fold<Map<String, UserLocation>>({}, (locationsMap, location) {
                // Keep only the most recent location for each user
                // and only if the user is broadcasting their location
                if (!locationsMap.containsKey(location.id) ||
                    (locationsMap[location.id]!
                        .updatedAt
                        .isBefore(location.updatedAt))) {
                  locationsMap[location.id!] = location;
                }
                return locationsMap;
              })
              .values
              .where((location) => location.isBroadcasting)
              .toList();

          state = state.copyWith(userLocations: updatedLocations);
        },
      );
    } on Exception catch (e) {
      state = state.copyWith(exception: e);
    }
  }

  Future<void> broadcastCurrentLocation() async {
    _currentLocationStream = _locationService.streamCurrentLocation();
    _locationSubscription = _currentLocationStream.listen(_updateUserLocation);
    state = state.copyWith(isBroadcastingLocation: true);
  }

  Future<void> stopCurrentLocationBroadcast() async {
    state = state.copyWith(isBroadcastingLocation: false);
    final lastPosition = await _locationService.getCurrentLocation();
    await Future.wait([
      _locationSubscription?.cancel() ?? Future.value(),
      _userLocationRepository.createOrUpdate(
        UserLocation(
          id: _userId,
          latitude: lastPosition.latitude,
          longitude: lastPosition.longitude,
          isBroadcasting: false,
          updatedAt: DateTime.now(),
        ),
      ),
    ]);
  }

  Future<void> _updateUserLocation(Position position) async {
    await _userLocationRepository.createOrUpdate(
      UserLocation(
        id: _userId,
        latitude: position.latitude,
        longitude: position.longitude,
        isBroadcasting: true,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _userLocationsSubscription?.cancel();
    super.dispose();
  }
}
