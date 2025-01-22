import 'package:where_im_at/domain/models/user_info.dart';
import 'package:where_im_at/domain/models/user_location.dart';

class UserInfoAndLocation {
  const UserInfoAndLocation({
    required this.info,
    required this.location,
  });

  final UserInfo info;
  final UserLocation location;
}
