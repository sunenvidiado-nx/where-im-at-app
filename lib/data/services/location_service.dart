import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:where_im_at/app/router/router_config.dart';
import 'package:where_im_at/config/dependency_injection/di_keys.dart';
import 'package:where_im_at/domain/models/address_response.dart';

@singleton
class LocationService {
  LocationService(
    this._router,
    @Named(DiKeys.geocodingApi) this._geoCodingApi,
    @Named(DiKeys.projectOsrmApi) this._projectOsrmApi,
  );

  final GoRouter _router;
  final Dio _geoCodingApi;
  final Dio _projectOsrmApi;

  final _geocodeCache = <String, AddressDetails>{};

  Future<void> initialize() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception();

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      return;
    } catch (_) {
      _router.go(Routes.noLocationServices);
    }
  }

  Future<Position> getCurrentLocation([
    LocationAccuracy accuracy = LocationAccuracy.high,
  ]) async {
    await initialize();
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            LocationSettings(accuracy: accuracy, distanceFilter: 100),
      );
      return position;
    } catch (error) {
      _router.go(Routes.noLocationServices);
      rethrow;
    }
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

  /// Returns a list of waypoints representing the route between two coordinates via OSRM API
  Future<AddressDetails> getAddressByCoords(
    double latitude,
    double longitude,
  ) async {
    final cacheKey = '$latitude,$longitude';

    if (_geocodeCache.containsKey(cacheKey)) {
      return _geocodeCache[cacheKey]!;
    }

    final response = await _geoCodingApi
        .get('/reverse', queryParameters: {'lat': latitude, 'lon': longitude});

    final address = AddressResponseMapper.fromMap(response.data!).address;

    _geocodeCache[cacheKey] = address;

    return address;
  }

  /// Returns a polyline string representing the route between two coordinates via OSRM API
  Future<List<LatLng>> getNavigationPath(
    LatLng origin,
    LatLng destination,
  ) async {
    final response = await _projectOsrmApi.get(
      '/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}',
      queryParameters: {'overview': 'simplified'},
    );

    return _parsePolyline((response.data!['routes'] as List).first['geometry']);
  }

  /// Decodes a polyline string into a list of LatLng coordinates
  List<LatLng> _parsePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      // Decode latitude
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      // Decode longitude
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      // Convert to actual latitude/longitude values
      double latitude = lat * 1e-5;
      double longitude = lng * 1e-5;

      points.add(LatLng(latitude, longitude));
    }

    return points;
  }
}
