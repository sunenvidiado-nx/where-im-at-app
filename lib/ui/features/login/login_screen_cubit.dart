import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/data/services/auth_service.dart';
import 'package:where_im_at/utils/extensions/exception_extensions.dart';

part 'login_screen_state.dart';
part 'login_screen_cubit.mapper.dart';

@injectable
class LoginScreenCubit extends Cubit<LoginScreenState> {
  LoginScreenCubit(this._authService) : super(const LoginScreenState());

  final AuthService _authService;

  Future<void> login(String email, String password) async {
    try {
      emit(state.copyWith(loading: true));
      await _authService.signInWithEmail(email, password);
      emit(state.copyWith(didLogIn: true));
    } on Exception catch (e) {
      emit(state.copyWith(errorMessage: e.errorMessage));
    } finally {
      emit(state.copyWith(loading: false, errorMessage: null));
    }
  }
}
