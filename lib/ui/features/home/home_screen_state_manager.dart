import 'dart:async';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';
import 'package:where_im_at/data/repositories/user_info_repository.dart';
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
    this._userInfoRepository,
    this._secureStorage,
  ) : super(const HomeScreenState());

  final AuthService _authService;
  final LocationService _locationService;
  final UserLocationRepository _userLocationRepository;
  final UserInfoRepository _userInfoRepository;
  final FlutterSecureStorage _secureStorage;

  // Generate keys here: http://bit.ly/random-strings-generator
  static const _isBroadcastingLocationKey = '3VWwaaP7gw05';

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
      final userInfo = await _userInfoRepository.getUserInfo(_userId);

      if (userInfo == null) {
        state = state.copyWith(shouldSetUpProfile: true);
        return;
      }

      final currentLocation = await _locationService
          .getCurrentLocation()
          .then((position) => LatLng(position.latitude, position.longitude));

      state = state.copyWith(initialLocation: currentLocation);

      final isBroadcastingLocation =
          await _secureStorage.read(key: _isBroadcastingLocationKey);

      if (isBroadcastingLocation == 'true') await broadcastCurrentLocation();

      _userLocationsStream = _userLocationRepository.streamUserLocations();
      _userLocationsSubscription = _userLocationsStream
          .listen((data) => state = state.copyWith(userLocations: data));
    } on Exception catch (e) {
      state = state.copyWith(exception: e);
    } finally {
      state = state.copyWith(exception: null);
    }
  }

  Future<void> broadcastCurrentLocation() async {
    _currentLocationStream = _locationService.streamCurrentLocation();
    _locationSubscription = _currentLocationStream.listen(_updateUserLocation);
    state = state.copyWith(isBroadcastingLocation: true);
    await _secureStorage.write(key: _isBroadcastingLocationKey, value: 'true');
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
      _secureStorage.delete(key: _isBroadcastingLocationKey),
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
