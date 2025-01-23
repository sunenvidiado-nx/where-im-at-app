part of 'set_up_profile_screen_cubit.dart';

sealed class SetUpProfileScreenState {
  const SetUpProfileScreenState();
}

final class SetUpProfileScreenInitial extends SetUpProfileScreenState {
  const SetUpProfileScreenInitial({this.photo});
  
  final File? photo;
}

final class SetUpProfileScreenLoading extends SetUpProfileScreenState {
  const SetUpProfileScreenLoading({this.photo});
  
  final File? photo;
}

final class SetUpProfileScreenError extends SetUpProfileScreenState {
  const SetUpProfileScreenError(this.errorMessage, {this.photo});

  final String errorMessage;
  final File? photo;
}

final class SetUpProfileScreenSuccess extends SetUpProfileScreenState {
  const SetUpProfileScreenSuccess();
}
