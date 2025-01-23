import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/data/repositories/user_info_repository.dart';
import 'package:where_im_at/data/repositories/user_location_repository.dart';
import 'package:where_im_at/data/services/auth_service.dart';
import 'package:where_im_at/data/services/location_service.dart';
import 'package:where_im_at/domain/models/user_info.dart';
import 'package:where_im_at/domain/models/user_location.dart';
import 'package:where_im_at/utils/extensions/exception_extensions.dart';

part 'user_marker_info_bottom_sheet_state.dart';

@injectable
class UserMarkerInfoBottomSheetCubit
    extends Cubit<UserMarkerInfoBottomSheetState> {
  UserMarkerInfoBottomSheetCubit(
    this._locationService,
    this._userInfoRepository,
    this._userLocationRepository,
    this._authService,
  ) : super(const UserMarkerInfoBottomSheetInitial());

  final LocationService _locationService;
  final UserInfoRepository _userInfoRepository;
  final UserLocationRepository _userLocationRepository;
  final AuthService _authService;

  Future<void> initialize(String userId) async {
    emit(const UserMarkerInfoBottomSheetLoading());

    try {
      final [userInfo, userLocation] = await Future.wait([
        _userInfoRepository.getUserInfo(userId),
        _userLocationRepository.getByUserId(userId),
      ]);

      if (userInfo == null || userLocation == null) {
        throw Exception('Could not retrieve user info for user $userId');
      }

      userInfo as UserInfo;
      userLocation as UserLocation;

      final userAddress = await _locationService.findPlacesByCoords(
        userLocation.latitude.toDouble(),
        userLocation.longitude.toDouble(),
      );

      emit(
        UserMarkerInfoBottomSheetLoaded(
          isCurrentUser: userInfo.id == _authService.currentUser!.uid,
          username: userInfo.username,
          photoUrl: userInfo.photoUrl,
          approximateLocation: userAddress.first.name,
          city: userAddress.first.locality,
        ),
      );
    } on Exception catch (e) {
      emit(UserMarkerInfoBottomSheetError(e.errorMessage));
    }
  }
}
