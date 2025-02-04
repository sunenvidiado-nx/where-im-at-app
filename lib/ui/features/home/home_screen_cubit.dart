import 'dart:async';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:where_im_at/data/repositories/user_info_repository.dart';
import 'package:where_im_at/data/repositories/user_location_repository.dart';
import 'package:where_im_at/data/services/auth_service.dart';
import 'package:where_im_at/data/services/location_service.dart';
import 'package:where_im_at/domain/models/user_info.dart';
import 'package:where_im_at/domain/models/user_location.dart';
import 'package:where_im_at/utils/exceptions/exception_handler.dart';
import 'package:where_im_at/utils/extensions/exception_extensions.dart';

part 'home_screen_cubit.mapper.dart';
part 'home_screen_state.dart';

@injectable
class HomeScreenCubit extends Cubit<HomeScreenState> with ExceptionHandler {
  HomeScreenCubit(
    this._authService,
    this._locationService,
    this._userLocationRepository,
    this._userInfoRepository,
    this._backgroundService,
  ) : super(const HomeScreenState());

  final AuthService _authService;
  final LocationService _locationService;
  final UserLocationRepository _userLocationRepository;
  final UserInfoRepository _userInfoRepository;
  final FlutterBackgroundService _backgroundService;

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
    await guard(
      () async {
        emit(state.copyWith(isLoading: true));
        final userInfo = await _userInfoRepository.getUserInfo(_userId);

        if (userInfo == null) {
          return emit(state.copyWith(shouldRedirectToSetUpProfile: true));
        }

        final currentLocation = await _locationService
            .getCurrentLocation()
            .then((position) => LatLng(position.latitude, position.longitude));

        final isBroadcastingLocation = await isUserBroadcastingLocation();

        emit(
          state.copyWith(
            initialLocation: currentLocation,
            isBroadcastingLocation: isBroadcastingLocation,
            userLocations: const [],
          ),
        );

        if (isBroadcastingLocation) {
          await broadcastCurrentLocation();
        } else {
          if (await _backgroundService.isRunning()) {
            _backgroundService.invoke('stopService');
          }
        }

        _userLocationsStream = _userLocationRepository.streamUserLocations();
        _userLocationsSubscription = _userLocationsStream.listen((data) {
          emit(state.copyWith(userLocations: data));
        });
      },
      onError: (error, stackTrace) {
        if (error is Exception) {
          emit(
            state.copyWith(
              errorMessage: error.errorMessage,
              isLoading: false,
            ),
          );
        }
      },
      onSuccess: (_) => emit(state.copyWith(isLoading: false)),
    );
  }

  Future<void> broadcastCurrentLocation() async {
    await guard(
      () async {
        _currentLocationStream = _locationService.streamCurrentLocation();
        _locationSubscription =
            _currentLocationStream.listen(_updateUserLocation);
        emit(state.copyWith(isBroadcastingLocation: true));
        _backgroundService.startService();
      },
      onError: (error, stackTrace) async {
        await stopCurrentLocationBroadcast();
      },
    );
  }

  Future<void> stopCurrentLocationBroadcast() async {
    await guard(
      () async {
        emit(state.copyWith(isLoading: true));
        _backgroundService.invoke('stopService');
        stopCurrentNavigation();

        final finalLocation = await _locationService.getCurrentLocation();

        // Clean up subscriptions and update final location
        await Future.wait([
          _locationSubscription?.cancel() ?? Future.value(),
          _userLocationRepository.createOrUpdate(
            UserLocation(
              id: _userId,
              latitude: finalLocation.latitude,
              longitude: finalLocation.longitude,
              isBroadcasting: false,
              updatedAt: DateTime.now(),
            ),
          ),
        ]);

        emit(state.copyWith(isBroadcastingLocation: false));
      },
      onSuccess: (_) => emit(state.copyWith(isLoading: false)),
      onError: (_, __) => emit(state.copyWith(isLoading: false)),
    );
  }

  Future<UserInfo?> getUserInfo(String userId) async {
    UserInfo? userInfo;

    await guard(
      () async {
        userInfo = await _userInfoRepository.getUserInfo(userId);

        if (userInfo == null) {
          throw Exception('Could not retrieve user info for user $userId');
        }
      },
      onError: (error, stackTrace) {
        if (error is Exception) {
          emit(state.copyWith(errorMessage: error.errorMessage));
        }
      },
    );

    return userInfo;
  }

  Future<void> startNavigatingToUser(String userId) async {
    await guard(
      () async {
        final [destination, origin] = await Future.wait([
          _userLocationRepository.getByUserId(userId),
          _locationService.getCurrentLocation(),
        ]);

        destination as UserLocation?;
        origin as Position;

        if (destination == null) {
          throw Exception('Could not find location for user $userId');
        }

        final path = await _locationService.getNavigationPath(
          LatLng(origin.latitude, origin.longitude),
          destination.latLong,
        );

        emit(state.copyWith(userToUserRoute: path, userIdToNavigateTo: userId));
      },
      onError: (error, stackTrace) {
        if (error is Exception) {
          emit(state.copyWith(errorMessage: error.errorMessage));
        }
      },
    );
  }

  void stopCurrentNavigation() {
    emit(state.copyWith(userToUserRoute: null, userIdToNavigateTo: null));
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

  Future<bool> isUserBroadcastingLocation() async {
    final userLocation = await _userLocationRepository.getByUserId(_userId);
    return userLocation?.isBroadcasting ?? false;
  }

  bool isNavigatingToUser(String userId) {
    return state.userIdToNavigateTo == userId;
  }

  bool isCurrentlyNavigating() {
    return state.userIdToNavigateTo != null;
  }

  @override
  Future<void> close() async {
    _locationSubscription?.cancel();
    _userLocationsSubscription?.cancel();
    await super.close();
  }
}
