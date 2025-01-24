import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/data/repositories/user_info_repository.dart';
import 'package:where_im_at/data/repositories/user_location_repository.dart';
import 'package:where_im_at/data/services/auth_service.dart';
import 'package:where_im_at/data/services/location_service.dart';
import 'package:where_im_at/domain/models/user_info.dart';
import 'package:where_im_at/domain/models/user_location.dart';
import 'package:where_im_at/utils/extensions/exception_extensions.dart';

part 'user_info_bottom_sheet_state.dart';

@injectable
class UserInfoBottomSheetCubit extends Cubit<UserInfoBottomSheetState> {
  UserInfoBottomSheetCubit(
    this._locationService,
    this._userInfoRepository,
    this._userLocationRepository,
    this._authService,
  ) : super(const UserInfoBottomSheetInitial());

  final LocationService _locationService;
  final UserInfoRepository _userInfoRepository;
  final UserLocationRepository _userLocationRepository;
  final AuthService _authService;

  Future<void> initialize(String userId) async {
    emit(const UserInfoBottomSheetLoading());

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

      final address = await _locationService.getAddressByCoords(
        userLocation.latitude.toDouble(),
        userLocation.longitude.toDouble(),
      );

      emit(
        UserInfoBottomSheetLoaded(
          isCurrentUser: userInfo.id == _authService.currentUser!.uid,
          username: userInfo.username,
          photoUrl: userInfo.photoUrl,
          address: address.formattedAddress,
        ),
      );
    } on Exception catch (e) {
      emit(UserInfoBottomSheetError(e.errorMessage));
    }
  }
}
