import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:where_im_at/app/router/routes.dart';
import 'package:where_im_at/ui/common_widgets/snackbars/app_snackbar.dart';
import 'package:where_im_at/ui/features/home/home_screen_cubit.dart';
import 'package:where_im_at/ui/features/home/widgets/interactive_map.dart';
import 'package:where_im_at/utils/extensions/exception_extensions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
        listener: _listener,
        builder: (context, state) => InteractiveMap(
          initialLocation: state.initialLocation,
          userLocations: state.userLocations,
        ),
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  void _listener(BuildContext context, HomeScreenState state) {
    if (state.exception != null) {
      context.showSnackbar(
        (state.exception as Exception).errorMessage,
        type: AppSnackbarType.error,
      );
    }

    if (state.shouldSetUpProfile) {
      context.go(Routes.setUpProfile);
    }
  }

  Widget _buildFab(BuildContext context) {
    return BlocSelector<HomeScreenCubit, HomeScreenState, bool>(
      selector: (state) => state.isBroadcastingLocation,
      builder: (context, isBroadcastingLocation) {
        return FloatingActionButton(
          child: Icon(
            isBroadcastingLocation
                ? Icons.my_location_outlined
                : Icons.location_disabled_outlined,
          ),
          onPressed: () {
            if (isBroadcastingLocation) {
              _cubit.stopCurrentLocationBroadcast();
            } else {
              _cubit.broadcastCurrentLocation();
            }
          },
        );
      },
    );
  }
}
