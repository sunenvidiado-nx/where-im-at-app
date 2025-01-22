part of 'login_screen_cubit.dart';

@MappableClass()
class LoginScreenState with LoginScreenStateMappable {
  const LoginScreenState({
    this.loading = false,
    this.didLogIn = false,
    this.errorMessage,
  });

  final bool loading;
  final bool didLogIn;
  final String? errorMessage;
}
