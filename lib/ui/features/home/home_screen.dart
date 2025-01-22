import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';
import 'package:where_im_at/app/router/routes.dart';
import 'package:where_im_at/ui/common_widgets/snackbars/app_snackbar.dart';
import 'package:where_im_at/ui/features/home/home_screen_state_manager.dart';
import 'package:where_im_at/ui/features/home/widgets/interactive_map.dart';
import 'package:where_im_at/utils/extensions/exception_extensions.dart';

class HomeScreen
    extends ManagedStatefulWidget<HomeScreenStateManager, HomeScreenState> {
  const HomeScreen({super.key});

  @override
  HomeScreenStateManager createStateManager() =>
      GetIt.I<HomeScreenStateManager>();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState
    extends ManagedState<HomeScreenStateManager, HomeScreenState, HomeScreen> {
  @override
  void initState() {
    super.initState();
    stateManager
      ..addListener(
        (state) {
          if (state.exception != null) {
            context.showSnackbar(
              (state.exception as Exception).errorMessage,
              type: AppSnackbarType.error,
            );
          }

          if (state.shouldSetUpProfile) {
            context.go(Routes.setUpProfile);
          }
        },
      )
      ..initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InteractiveMap(
        initialLocation: state.initialLocation,
        userLocations: state.userLocations,
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      child: Icon(
        state.isBroadcastingLocation
            ? Icons.my_location_outlined
            : Icons.location_disabled_outlined,
      ),
      onPressed: () {
        if (state.isBroadcastingLocation) {
          stateManager.stopCurrentLocationBroadcast();
        } else {
          stateManager.broadcastCurrentLocation();
        }
      },
    );
  }
}
