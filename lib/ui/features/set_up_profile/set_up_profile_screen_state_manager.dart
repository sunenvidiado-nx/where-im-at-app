import 'dart:io';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';
import 'package:where_im_at/data/repositories/user_info_repository.dart';
import 'package:where_im_at/data/services/auth_service.dart';
import 'package:where_im_at/data/services/default_profile_picture_service.dart';
import 'package:where_im_at/domain/models/user_info.dart';
import 'package:where_im_at/utils/extensions/exception_extensions.dart';

part 'set_up_profile_screen_state.dart';
part 'set_up_profile_screen_state_manager.mapper.dart';

@injectable
class SetUpProfileScreenStateManager
    extends StateManager<SetUpProfileScreenState> {
  SetUpProfileScreenStateManager(
    this._userInfoRepository,
    this._authService,
    this._defaultProfilePictureService,
  ) : super(const SetUpProfileScreenState());

  final UserInfoRepository _userInfoRepository;
  final AuthService _authService;
  final DefaultProfilePictureService _defaultProfilePictureService;

  late final _picker = ImagePicker();

  Future<void> selectPhoto(bool useCamera) async {
    final pickedFile = await _picker.pickImage(
      source: useCamera ? ImageSource.camera : ImageSource.gallery,
      preferredCameraDevice: CameraDevice.front,
    );

    if (pickedFile != null) {
      state = state.copyWith(photo: File(pickedFile.path));
    }
  }

  Future<void> updateUserInfo(String username) async {
    try {
      state = state.copyWith(isLoading: true);

      final photoUrl = state.photo == null
          ? await _defaultProfilePictureService.getUrl()
          : await _userInfoRepository.uploadUserPhoto(
              _authService.currentUser!.uid,
              state.photo!,
            );

      await _userInfoRepository.createOrUpdate(
        UserInfo(
          id: _authService.currentUser!.uid,
          username: username,
          photoUrl: photoUrl,
          updatedAt: DateTime.now(),
        ),
      );

      state = state.copyWith(didSetUpProfile: true);
    } on Exception catch (e) {
      state = state.copyWith(errorMessage: e.errorMessage);
    } finally {
      state = state.copyWith(isLoading: false, errorMessage: null);
    }
  }
}
