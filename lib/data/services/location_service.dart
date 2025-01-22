import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/l10n/l10n.dart';

@singleton
class LocationService {
  const LocationService();

  Future<void> initialize() async {
    try {
      var serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(l10n.locationServiceDisabledMessage);
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          throw Exception(l10n.locationServiceDisabledMessage);
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(l10n.locationServiceDisabledMessage);
      }
    } catch (e) {
      // TODO Redirect to error page
    }
  }

  Future<Position> getCurrentLocation([
    LocationAccuracy accuracy = LocationAccuracy.high,
  ]) async {
    return Geolocator.getCurrentPosition(
      locationSettings:
          LocationSettings(accuracy: accuracy, distanceFilter: 100),
    );
  }

  Stream<Position> streamCurrentLocation([
    LocationAccuracy accuracy = LocationAccuracy.bestForNavigation,
  ]) =>
      Geolocator.getPositionStream(
        locationSettings:
            LocationSettings(accuracy: accuracy, distanceFilter: 100),
      );
}
