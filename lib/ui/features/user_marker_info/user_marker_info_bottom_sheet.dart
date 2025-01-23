import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:where_im_at/ui/common_widgets/snackbars/app_snackbar.dart';
import 'package:where_im_at/ui/features/user_marker_info/user_marker_info_bottom_sheet_cubit.dart';
import 'package:where_im_at/utils/constants/happy_kaomojis.dart';
import 'package:where_im_at/utils/constants/ui_constants.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';

class UserMarkerInfoBottomSheet extends StatefulWidget {
  const UserMarkerInfoBottomSheet(this.userId, {super.key});

  final String userId;

  @override
  State<UserMarkerInfoBottomSheet> createState() =>
      _UserMarkerInfoBottomSheetState();
}

class _UserMarkerInfoBottomSheetState extends State<UserMarkerInfoBottomSheet> {
  @override
  void initState() {
    super.initState();
    context.read<UserMarkerInfoBottomSheetCubit>().initialize(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserMarkerInfoBottomSheetCubit,
        UserMarkerInfoBottomSheetState>(
      builder: (context, state) => switch (state) {
        final UserMarkerInfoBottomSheetLoaded state =>
          _buildLoadedState(context, state),
        final UserMarkerInfoBottomSheetError state =>
          _buildErrorState(context, state),
        _ => _buildLoadedState(context, null),
      },
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    UserMarkerInfoBottomSheetLoaded? state,
  ) {
    final isLoading = state == null;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
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
              CircleAvatar(
                radius: 54,
                backgroundColor: context.colorScheme.surface,
                backgroundImage: !isLoading
                    ? CachedNetworkImageProvider(state.photoUrl)
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
                        ? 'planet earth' // Placeholder text
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
                            child: ElevatedButton(
                              onPressed: _onShowWayPressed,
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
                              child: Row(
                                children: [
                                  Text(
                                    context.l10n.userMarkerInfoShowWayButton,
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.turn_sharp_right_outlined,
                                    size: 22,
                                    color: context.colorScheme.surface,
                                  ),
                                ],
                              ),
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

  Future<void> _onShowWayPressed() async {
    // TODO Implement
    context.showSnackbar(
      'Di ko pa to na-implement ehe 😗✌🏼',
      type: AppSnackbarType.success,
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    UserMarkerInfoBottomSheetError state,
  ) {
    return Center(
      child: Text(
        state.errorMessage,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
