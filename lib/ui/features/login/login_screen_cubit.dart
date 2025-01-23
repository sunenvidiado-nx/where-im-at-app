import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/data/services/auth_service.dart';
import 'package:where_im_at/utils/extensions/exception_extensions.dart';

part 'login_screen_state.dart';

@injectable
class LoginScreenCubit extends Cubit<LoginScreenState> {
  LoginScreenCubit(this._authService) : super(const LoginScreenInitial());

  final AuthService _authService;

  Future<void> login(String email, String password) async {
    try {
      emit(const LoginScreenLoading());
      await _authService.signInWithEmail(email, password);
      emit(const LoginScreenSuccess());
    } on Exception catch (e) {
      emit(LoginScreenError(e.errorMessage));
    }
  }
}
