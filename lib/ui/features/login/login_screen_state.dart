part of 'login_screen_cubit.dart';

sealed class LoginScreenState {
  const LoginScreenState();
}

final class LoginScreenInitial extends LoginScreenState {
  const LoginScreenInitial();
}

final class LoginScreenLoading extends LoginScreenState {
  const LoginScreenLoading();
}

final class LoginScreenError extends LoginScreenState {
  const LoginScreenError(this.errorMessage);

  final String errorMessage;
}

final class LoginScreenSuccess extends LoginScreenState {
  const LoginScreenSuccess();
}
