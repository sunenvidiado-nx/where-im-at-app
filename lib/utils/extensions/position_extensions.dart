import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';

extension PositionExtensions on Position {
  LatLng toLatLng() => LatLng.degree(latitude, longitude);
}
