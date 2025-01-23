import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:where_im_at/data/repositories/user_info_repository.dart';
import 'package:where_im_at/data/repositories/user_location_repository.dart';
import 'package:where_im_at/data/services/auth_service.dart';
import 'package:where_im_at/data/services/location_service.dart';
import 'package:where_im_at/domain/models/address_response.dart';
import 'package:where_im_at/domain/models/user_info.dart';
import 'package:where_im_at/domain/models/user_location.dart';
import 'package:where_im_at/utils/extensions/exception_extensions.dart';

part 'home_screen_cubit.mapper.dart';
part 'home_screen_state.dart';

@injectable
class HomeScreenCubit extends Cubit<HomeScreenState> {
  HomeScreenCubit(
    this._authService,
    this._locationService,
    this._userLocationRepository,
    this._userInfoRepository,
    this._secureStorage,
  ) : super(const HomeScreenInitial());

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
      emit(const HomeScreenLoading());
      final userInfo = await _userInfoRepository.getUserInfo(_userId);

      if (userInfo == null) {
        return emit(const HomeScreenShouldRedirectToSetUpProfile());
      }

      final currentLocation = await _locationService
          .getCurrentLocation()
          .then((position) => LatLng(position.latitude, position.longitude));

      final isBroadcastingLocation =
          await _secureStorage.read(key: _isBroadcastingLocationKey) == 'true';

      emit(
        HomeScreenLoaded(
          initialLocation: currentLocation,
          isBroadcastingLocation: isBroadcastingLocation,
          userLocations: const [],
        ),
      );

      if (isBroadcastingLocation) await broadcastCurrentLocation();

      _userLocationsStream = _userLocationRepository.streamUserLocations();
      _userLocationsSubscription = _userLocationsStream.listen((data) {
        final currentState = state;
        if (currentState is HomeScreenLoaded &&
            !const DeepCollectionEquality()
                .equals(currentState.userLocations, data)) {
          emit(currentState.copyWith(userLocations: data));
        }
      });
    } on Exception catch (e) {
      emit(HomeScreenError(e.errorMessage));
    }
  }

  Future<void> broadcastCurrentLocation() async {
    try {
      final currentState = state;
      if (currentState is! HomeScreenLoaded) return;

      _currentLocationStream = _locationService.streamCurrentLocation();
      _locationSubscription =
          _currentLocationStream.listen(_updateUserLocation);
      emit(currentState.copyWith(isBroadcastingLocation: true));
      await _secureStorage.write(
        key: _isBroadcastingLocationKey,
        value: 'true',
      );
    } catch (e) {
      await stopCurrentLocationBroadcast();
      rethrow;
    }
  }

  Future<void> stopCurrentLocationBroadcast() async {
    final currentState = state;
    if (currentState is! HomeScreenLoaded) return;

    emit(currentState.copyWith(isBroadcastingLocation: false));

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

  Future<UserInfo> getUserInfo(String userId) async {
    try {
      final userInfo = await _userInfoRepository.getUserInfo(userId);

      if (userInfo == null) {
        throw Exception('Could not retrieve user info for user $userId');
      }

      return userInfo;
    } on Exception catch (e) {
      emit(HomeScreenError(e.errorMessage));
      rethrow; // Handle this better
    }
  }

  Future<AddressDetails> lookUpLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      return _locationService.getAddressByCoords(latitude, longitude);
    } on Exception catch (e) {
      emit(HomeScreenError(e.errorMessage));
      rethrow;
    }
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
  Future<void> close() async {
    _locationSubscription?.cancel();
    _userLocationsSubscription?.cancel();
    await super.close();
  }
}
