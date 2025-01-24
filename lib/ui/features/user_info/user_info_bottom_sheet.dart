import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:where_im_at/ui/features/user_info/user_info_bottom_sheet_cubit.dart';
import 'package:where_im_at/utils/constants/happy_kaomojis.dart';
import 'package:where_im_at/utils/constants/ui_constants.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';

class UserInfoBottomSheet extends StatefulWidget {
  const UserInfoBottomSheet({
    required this.userId,
    required this.currentUserIsNavigating,
    required this.isNavigatingToThisMarker,
    super.key,
  });

  final String userId;
  final bool currentUserIsNavigating;
  final bool isNavigatingToThisMarker;

  @override
  State<UserInfoBottomSheet> createState() => _UserInfoBottomSheetState();
}

class _UserInfoBottomSheetState extends State<UserInfoBottomSheet> {
  @override
  void initState() {
    super.initState();
    context.read<UserInfoBottomSheetCubit>().initialize(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserInfoBottomSheetCubit, UserInfoBottomSheetState>(
      builder: (context, state) => switch (state) {
        final UserInfoBottomSheetLoaded state =>
          _buildLoadedState(context, state),
        final UserInfoBottomSheetError state =>
          _buildErrorState(context, state),
        _ => _buildLoadedState(context, null),
      },
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    UserInfoBottomSheetLoaded? state,
  ) {
    final isLoading = state == null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(UiConstants.borderRadius),
          topRight: Radius.circular(UiConstants.borderRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Skeletonizer(
          enabled: isLoading,
          effect: PulseEffect(
            from: context.colorScheme.shadow.withAlpha(25),
            to: context.colorScheme.shadow.withAlpha(10),
          ),
          textBoneBorderRadius: TextBoneBorderRadius(BorderRadius.circular(4)),
          enableSwitchAnimation: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 18),
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorScheme.primary.withAlpha(20),
                ),
                child: !isLoading
                    ? CircleAvatar(
                        radius: 54,
                        backgroundColor: context.colorScheme.surface,
                        backgroundImage:
                            CachedNetworkImageProvider(state.photoUrl),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                state?.isCurrentUser == true
                    ? '${state?.username} (${context.l10n.you})'
                    : state?.username ?? 'username',
                style: Theme.of(context).primaryTextTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.55,
                child: Text(
                  context.l10n.somewhereInLocation(
                    state == null
                        ? 'this planet called Earth, our home' // Placeholder text
                        : state.address,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.primary.withAlpha(170),
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 60,
                child: state?.isCurrentUser == true
                    ? Skeleton.ignore(
                        child: Text(
                          HappyKaomojis.random,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color:
                                    context.colorScheme.primary.withAlpha(30),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Skeleton.ignore(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (widget.isNavigatingToThisMarker) {
                                  return _stopNavigation();
                                }

                                if (widget.currentUserIsNavigating) {
                                  return _showNavigationWarningBottomSheet();
                                }

                                return _startNavigation();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                elevation: 4,
                                shadowColor: isLoading
                                    ? Colors.transparent
                                    : context.colorScheme.primary
                                        .withAlpha(120),
                              ),
                              label: Text(
                                widget.isNavigatingToThisMarker
                                    ? context.l10n.userInfoButtonStopNavigating
                                    : context.l10n.userInfoActionButton,
                              ),
                              icon: Icon(
                                widget.isNavigatingToThisMarker
                                    ? Icons.stop_circle_outlined
                                    : Icons.turn_sharp_right_outlined,
                                size: 22,
                              ),
                              iconAlignment: IconAlignment.end,
                            ),
                          ),
                        ],
                      ),
              ),
              const SafeArea(child: SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    UserInfoBottomSheetError state,
  ) {
    return Container(
      color: context.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.errorMessage,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: context.colorScheme.primary.withAlpha(170)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: context.pop,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                elevation: 4,
                shadowColor: context.colorScheme.primary.withAlpha(120),
              ),
              label: Text(context.l10n.goBack),
              icon: const Icon(Icons.arrow_back, size: 22),
              iconAlignment: IconAlignment.end,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startNavigation() async {
    context.pop(widget.userId);
  }

  Future<void> _stopNavigation() async {
    context.pop(true);
  }

  Future<void> _showNavigationWarningBottomSheet() async {
    final shouldNavigate = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(UiConstants.borderRadius),
            topRight: Radius.circular(UiConstants.borderRadius),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.navigationWarningMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.primary.withAlpha(170),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => context.pop(false),
                    child: Text(context.l10n.cancelButton),
                  ),
                  ElevatedButton(
                    onPressed: () => context.pop(true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      elevation: 4,
                      shadowColor: context.colorScheme.primary.withAlpha(120),
                    ),
                    child: Text(context.l10n.getDirectionsButton),
                  ),
                ],
              ),
              const SafeArea(child: SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );

    if (shouldNavigate == true) await _startNavigation();
  }
}
