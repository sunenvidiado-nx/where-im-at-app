import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/data/repositories/user_info_repository.dart';
import 'package:where_im_at/data/services/auth_service.dart';
import 'package:where_im_at/data/services/default_profile_picture_service.dart';
import 'package:where_im_at/domain/models/user_info.dart';
import 'package:where_im_at/utils/exceptions/exception_handler.dart';
import 'package:where_im_at/utils/extensions/exception_extensions.dart';

part 'set_up_profile_screen_state.dart';

@injectable
class SetUpProfileScreenCubit extends Cubit<SetUpProfileScreenState>
    with ExceptionHandler {
  SetUpProfileScreenCubit(
    this._userInfoRepository,
    this._authService,
    this._defaultProfilePictureService,
  ) : super(const SetUpProfileScreenInitial());

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
      final photo = File(pickedFile.path);
      switch (state) {
        case SetUpProfileScreenInitial():
          emit(SetUpProfileScreenInitial(photo: photo));
        case SetUpProfileScreenLoading():
          emit(SetUpProfileScreenLoading(photo: photo));
        case SetUpProfileScreenError(errorMessage: final errorMessage):
          emit(SetUpProfileScreenError(errorMessage, photo: photo));
        case SetUpProfileScreenSuccess():
          break;
      }
    }
  }

  Future<void> updateUserInfo(String username) async {
    final currentPhoto = switch (state) {
      SetUpProfileScreenInitial(photo: final photo) => photo,
      SetUpProfileScreenLoading(photo: final photo) => photo,
      SetUpProfileScreenError(photo: final photo) => photo,
      SetUpProfileScreenSuccess() => null,
    };

    await guard(
      () async {
        emit(SetUpProfileScreenLoading(photo: currentPhoto));

        final photoUrl = currentPhoto == null
            ? await _defaultProfilePictureService.getUrl()
            : await _userInfoRepository.uploadUserPhoto(
                _authService.currentUser!.uid,
                currentPhoto,
              );

        await _userInfoRepository.createOrUpdate(
          UserInfo(
            id: _authService.currentUser!.uid,
            username: username,
            photoUrl: photoUrl,
            updatedAt: DateTime.now(),
          ),
        );

        emit(const SetUpProfileScreenSuccess());
      },
      onError: (error, stackTrace) {
        if (error is Exception) {
          emit(
            SetUpProfileScreenError(error.errorMessage, photo: currentPhoto),
          );
        }
      },
    );
  }
}
