import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/app/router/routes.dart';

@singleton
class LocationService {
  const LocationService(this._router);

  final GoRouter _router;

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
}
