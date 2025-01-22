import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/app/router/routes.dart';
import 'package:where_im_at/data/services/auth_service.dart';
import 'package:where_im_at/ui/features/home/home_screen.dart';
import 'package:where_im_at/ui/features/login/login_screen.dart';
import 'package:where_im_at/ui/features/register/register_screen.dart';
import 'package:where_im_at/ui/features/set_up_profile/set_up_profile_screen.dart';

@module
abstract class RouterConfig {
  @singleton
  GoRouter get goRouter {
    return GoRouter(
      routes: [
        GoRoute(
          path: Routes.root,
          name: Routes.root,
          redirect: (context, state) => Routes.home,
        ),
        GoRoute(
          path: Routes.home,
          name: Routes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: Routes.login,
          name: Routes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: Routes.register,
          name: Routes.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: Routes.setUpProfile,
          name: Routes.setUpProfile,
          builder: (context, state) => const SetUpProfileScreen(),
        ),
      ],
      redirect: (context, state) async {
        final location = state.uri.toString();
        final isLoggedIn = GetIt.I<AuthService>().isLoggedIn;

        // If the user is logged in, redirect to the home screen
        if (location == Routes.root && isLoggedIn ||
            location == Routes.login && isLoggedIn) {
          return Routes.home;
        }

        // If the user is not logged in, redirect to the login screen
        if (location == Routes.root && !isLoggedIn ||
            location == Routes.home && !isLoggedIn) {
          return Routes.login;
        }

        return null;
      },
    );
  }
}
