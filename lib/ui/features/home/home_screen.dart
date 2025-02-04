import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:where_im_at/app/router/router_config.dart';
import 'package:where_im_at/ui/common_widgets/snackbars/app_snackbar.dart';
import 'package:where_im_at/ui/features/home/home_screen_cubit.dart';
import 'package:where_im_at/ui/features/home/widgets/interactive_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    this.userIdToNavigate,
    this.shouldStopCurrentNavigation = false,
    super.key,
  });

  final String? userIdToNavigate;
  final bool shouldStopCurrentNavigation;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final _cubit = context.read<HomeScreenCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<HomeScreenCubit, HomeScreenState>(
        listener: _hadnleStateChange,
        buildWhen: (previous, current) =>
            previous.initialLocation != current.initialLocation ||
            previous.userLocations != current.userLocations ||
            previous.userToUserRoute != current.userToUserRoute,
        builder: (context, state) => InteractiveMap(
          initialLocation: state.initialLocation,
          userLocations: state.userLocations,
          userToUserRoute: state.userToUserRoute,
        ),
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  void _hadnleStateChange(BuildContext context, HomeScreenState state) {
    if (state.hasError) {
      context.showSnackbar(state.errorMessage!, type: AppSnackbarType.error);
    }

    if (state.shouldRedirectToSetUpProfile) {
      context.go(Routes.setUpProfile);
    }
  }

  Widget _buildFab(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      buildWhen: (previous, current) =>
          previous.isBroadcastingLocation != current.isBroadcastingLocation ||
          previous.isLoading != current.isLoading,
      builder: (context, state) {
        return FloatingActionButton(
          onPressed: state.isLoading
              ? null
              : () {
                  if (state.isBroadcastingLocation) {
                    _cubit.stopCurrentLocationBroadcast();
                  } else {
                    _cubit.broadcastCurrentLocation();
                  }
                },
          child: Icon(
            state.isBroadcastingLocation
                ? Icons.location_disabled_outlined
                : Icons.my_location_outlined,
          ),
        );
      },
    );
  }
}
