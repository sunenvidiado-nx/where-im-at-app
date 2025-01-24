// ignore_for_file: require_trailing_commas

part of 'router_config.dart';

abstract class Routes {
  static const root = '/';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const setUpProfile = '/set-up-profile';
  static const noLocationServices = '/no-location-services';

  static const _userInfo = '/user-info';
  static String userInfo(
    String userId, [
    bool? isNavigatingToThisMarker,
    bool? currentUserIsNavigating,
  ]) =>
      '$_userInfo/$userId${Uri(queryParameters: {
            if (currentUserIsNavigating != null)
              'currentUserIsNavigating': currentUserIsNavigating.toString(),
            if (isNavigatingToThisMarker != null)
              'isNavigatingToThisMarker': isNavigatingToThisMarker.toString(),
          })}';
}
