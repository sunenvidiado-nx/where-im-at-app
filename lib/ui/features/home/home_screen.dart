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
        builder: (context, state) => switch (state) {
          final HomeScreenLoaded state => InteractiveMap(
              initialLocation: state.initialLocation,
              userLocations: state.userLocations,
              userToUserRoute: state.userToUserRoute,
            ),
          _ => const InteractiveMap(userLocations: []),
        },
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  void _hadnleStateChange(BuildContext context, HomeScreenState state) {
    if (state is HomeScreenError) {
      context.showSnackbar(state.errorMessage, type: AppSnackbarType.error);
    }

    if (state is HomeScreenShouldRedirectToSetUpProfile) {
      context.go(Routes.setUpProfile);
    }
  }

  Widget _buildFab(BuildContext context) {
    return BlocSelector<HomeScreenCubit, HomeScreenState,
        ({bool isLoading, bool isBroadcasting})>(
      selector: (state) => (
        isLoading: state is HomeScreenLoading,
        isBroadcasting: switch (state) {
          HomeScreenLoaded(:final isBroadcastingLocation) =>
            isBroadcastingLocation,
          _ => false,
        },
      ),
      builder: (context, status) {
        return FloatingActionButton(
          onPressed: status.isLoading
              ? null
              : () {
                  if (status.isBroadcasting) {
                    _cubit.stopCurrentLocationBroadcast();
                  } else {
                    _cubit.broadcastCurrentLocation();
                  }
                },
          child: Icon(
            status.isBroadcasting
                ? Icons.location_disabled_outlined
                : Icons.my_location_outlined,
          ),
        );
      },
    );
  }
}
