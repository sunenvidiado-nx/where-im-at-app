import 'package:dart_mappable/dart_mappable.dart';
import 'package:injectable/injectable.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';
import 'package:where_im_at/data/services/auth_service.dart';
import 'package:where_im_at/utils/extensions/exception_extensions.dart';

part 'login_screen_state.dart';
part 'login_screen_state_manager.mapper.dart';

@injectable
class LoginScreenStateManager extends StateManager<LoginScreenState> {
  LoginScreenStateManager(this._authService) : super(const LoginScreenState());

  final AuthService _authService;

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(loading: true);
      await _authService.signInWithEmail(email, password);
      state = state.copyWith(didLogIn: true);
    } on Exception catch (e) {
      state = state.copyWith(errorMessage: e.errorMessage);
    } finally {
      state = state.copyWith(loading: false, errorMessage: null);
    }
  }
}
