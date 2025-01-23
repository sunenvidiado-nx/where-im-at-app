part of 'router_config.dart';

abstract class Routes {
  static const root = '/';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const setUpProfile = '/set-up-profile';
  static const noLocationServices = '/no-location-services';

  static const _userMarkerInfo = '/user-marker-info';
  static String userMarkerInfo(String userId) => '$_userMarkerInfo/$userId';
}
