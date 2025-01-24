import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/data/services/auth_service.dart';
import 'package:where_im_at/ui/common_widgets/pages/bottom_sheet_page.dart';
import 'package:where_im_at/ui/features/home/home_screen.dart';
import 'package:where_im_at/ui/features/home/home_screen_cubit.dart';
import 'package:where_im_at/ui/features/login/login_screen.dart';
import 'package:where_im_at/ui/features/login/login_screen_cubit.dart';
import 'package:where_im_at/ui/features/no_location_services/no_location_services_screen.dart';
import 'package:where_im_at/ui/features/register/register_screen.dart';
import 'package:where_im_at/ui/features/set_up_profile/set_up_profile_screen.dart';
import 'package:where_im_at/ui/features/set_up_profile/set_up_profile_screen_cubit.dart';
import 'package:where_im_at/ui/features/user_info/user_info_bottom_sheet.dart';
import 'package:where_im_at/ui/features/user_info/user_info_bottom_sheet_cubit.dart';

part 'routes.dart';

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
          path: Routes.noLocationServices,
          name: Routes.noLocationServices,
          builder: (context, state) => const NoLocationServicesScreen(),
        ),
        GoRoute(
          path: Routes.register,
          name: Routes.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: Routes.home,
          name: Routes.home,
          builder: (context, state) => BlocProvider(
            create: (_) => GetIt.I<HomeScreenCubit>(),
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: Routes.login,
          name: Routes.login,
          builder: (context, state) => BlocProvider(
            create: (_) => GetIt.I<LoginScreenCubit>(),
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: Routes.setUpProfile,
          name: Routes.setUpProfile,
          builder: (context, state) => BlocProvider(
            create: (_) => GetIt.I<SetUpProfileScreenCubit>(),
            child: const SetUpProfileScreen(),
          ),
        ),
        GoRoute(
          path: '${Routes._userInfo}/:userId',
          name: Routes._userInfo,
          pageBuilder: (context, state) => BottomSheetPage(
            child: BlocProvider(
              create: (_) => GetIt.I<UserInfoBottomSheetCubit>(),
              child: UserInfoBottomSheet(
                userId: state.pathParameters['userId']!,
                currentUserIsNavigating:
                    state.uri.queryParameters['currentUserIsNavigating'] ==
                        'true',
                isNavigatingToThisMarker:
                    state.uri.queryParameters['isNavigatingToThisMarker'] ==
                        'true',
              ),
            ),
          ),
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
