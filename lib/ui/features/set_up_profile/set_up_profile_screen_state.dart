part of 'set_up_profile_screen_cubit.dart';

@MappableClass()
class SetUpProfileScreenState with SetUpProfileScreenStateMappable {
  const SetUpProfileScreenState({
    this.isLoading = false,
    this.didSetUpProfile = false,
    this.photo,
    this.errorMessage,
  });

  final bool isLoading;
  final bool didSetUpProfile;
  final File? photo;
  final String? errorMessage;
}
