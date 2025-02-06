import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:where_im_at/app/router/router_config.dart';
import 'package:where_im_at/ui/common_widgets/snackbars/app_snackbar.dart';
import 'package:where_im_at/ui/features/home/home_screen_cubit.dart';
import 'package:where_im_at/ui/features/home/widgets/interactive_map.dart';
import 'package:where_im_at/utils/constants/ui_constants.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';
import 'package:where_im_at/utils/extensions/int_extensions.dart';

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
      body: Stack(
        children: [
          BlocConsumer<HomeScreenCubit, HomeScreenState>(
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
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: 180,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius:
                        BorderRadius.circular(UiConstants.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: context.colorScheme.shadow.withAlpha(20),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLocationToggle(),
                      _buildUserButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildLocationToggle() {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      buildWhen: (previous, current) =>
          previous.isBroadcastingLocation != current.isBroadcastingLocation ||
          previous.isLoading != current.isLoading,
      builder: (context, state) {
        return IconButton(
          onPressed: state.isLoading
              ? null
              : () {
                  if (state.isBroadcastingLocation) {
                    _cubit.stopCurrentLocationBroadcast();
                  } else {
                    _cubit.broadcastCurrentLocation();
                  }
                },
          icon: Icon(
            state.isBroadcastingLocation
                ? Icons.location_disabled_outlined
                : Icons.my_location_outlined,
          ),
        );
      },
    );
  }

  Widget _buildUserButton() {
    return PopupMenuButton(
      icon: const Icon(Icons.person_outline),
      popUpAnimationStyle: AnimationStyle(
        duration: 150.milliseconds,
        reverseDuration: 150.milliseconds,
      ),
      offset: const Offset(20, -66),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiConstants.borderRadius),
      ),
      elevation: 8,
      shadowColor: context.colorScheme.shadow.withAlpha(30),
      constraints: const BoxConstraints(minWidth: 40, maxWidth: 105),
      itemBuilder: (context) => [
        PopupMenuItem(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.exit_to_app_outlined, size: 20),
              const SizedBox(width: 5),
              Text(context.l10n.logOut),
            ],
          ),
          onTap: () async {
            var result = await showModalActionSheet(
              context: context,
              title: context.l10n.confirmLogoutMessage,
              actions: [
                SheetAction(
                  label: context.l10n.confirmLogoutButton,
                  key: 'logout',
                  isDestructiveAction: true,
                ),
              ],
            );

            if (result == 'logout') {
              await _cubit.logOut();
              // ignore: use_build_context_synchronously
              context.go(Routes.login);
            }
          },
        ),
      ],
    );
  }
}
