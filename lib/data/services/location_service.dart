import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlng/latlng.dart';
import 'package:where_im_at/l10n/app_localization.dart';
import 'package:where_im_at/utils/extensions/position_extensions.dart';

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

  Future<LatLng> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    return position.toLatLng();
  }
}
