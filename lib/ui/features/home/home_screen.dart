import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';
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
        (newState) {
          if (newState.exception != null) {
            context.showSnackbar(
              (newState.exception as Exception).errorMessage,
              type: AppSnackbarType.error,
            );
          }
        },
      )
      ..initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const InteractiveMap(),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      child: Icon(
        state.isBroadcastingLocation
            ? Icons.location_disabled_outlined
            : Icons.my_location_outlined,
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
