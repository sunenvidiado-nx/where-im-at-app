import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/app/router/router_config.dart';
import 'package:where_im_at/config/dependency_injection/di_keys.dart';
import 'package:where_im_at/domain/models/address_response.dart';

@singleton
class LocationService {
  LocationService(
    this._router,
    @Named(DiKeys.positionStackApi) this._apiClient,
  );

  final GoRouter _router;
  final Dio _apiClient;

  final _geocodeCache = <String, List<AddressData>>{};

  Future<void> initialize() async {
    try {
      var serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception();
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          throw Exception();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception();
      }
    } catch (_) {
      _router.go(Routes.noLocationServices);
    }
  }

  Future<Position> getCurrentLocation([
    LocationAccuracy accuracy = LocationAccuracy.high,
  ]) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _router.go(Routes.noLocationServices);
      throw Exception('Location services disabled');
    }
    return Geolocator.getCurrentPosition(
      locationSettings:
          LocationSettings(accuracy: accuracy, distanceFilter: 100),
    );
  }

  Stream<Position> streamCurrentLocation([
    LocationAccuracy accuracy = LocationAccuracy.bestForNavigation,
  ]) {
    return Geolocator.getPositionStream(
      locationSettings:
          LocationSettings(accuracy: accuracy, distanceFilter: 100),
    ).handleError((error) {
      _router.go(Routes.noLocationServices);
      throw error;
    });
  }

  Future<List<AddressData>> findPlacesByCoords(
    double latitude,
    double longitude,
  ) async {
    final cacheKey = '$latitude,$longitude';

    if (_geocodeCache.containsKey(cacheKey)) {
      return _geocodeCache[cacheKey]!;
    }

    final response =
        await _apiClient.get('/reverse', queryParameters: {'query': cacheKey});
    final addresses = AddressResponseMapper.fromMap(response.data!).data;

    _geocodeCache[cacheKey] = addresses;
    return addresses;
  }
}
