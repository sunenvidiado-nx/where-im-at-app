import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:where_im_at/app/router/router_config.dart';
import 'package:where_im_at/app/themes/app_assets.dart';
import 'package:where_im_at/ui/common_widgets/snackbars/app_snackbar.dart';
import 'package:where_im_at/ui/common_widgets/textfields/app_text_form_field.dart';
import 'package:where_im_at/ui/features/set_up_profile/set_up_profile_screen_cubit.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';

class SetUpProfileScreen extends StatefulWidget {
  const SetUpProfileScreen({super.key});

  @override
  State<SetUpProfileScreen> createState() => _SetUpProfileScreenState();
}

class _SetUpProfileScreenState extends State<SetUpProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  late final _cubit = context.read<SetUpProfileScreenCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SetUpProfileScreenCubit, SetUpProfileScreenState>(
      listener: _handleStateChange,
      builder: (context, state) => Scaffold(
        body: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              _buildTitle(),
              _buildProfileContent(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomButton(
          isLoading: state is SetUpProfileScreenLoading,
        ),
      ),
    );
  }

  void _handleStateChange(BuildContext context, SetUpProfileScreenState state) {
    if (state is SetUpProfileScreenError) {
      context.showSnackbar(state.errorMessage, type: AppSnackbarType.error);
    }

    if (state is SetUpProfileScreenSuccess) {
      context.go(Routes.home);
    }
  }

  Widget _buildTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 72, 24, 0),
        child: Center(
          child: Text(
            context.l10n.setUpProfileTitle,
            style: context.primaryTextTheme.headlineMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
        child: Column(
          children: [
            _buildProfileAvatar(),
            const SizedBox(height: 48),
            _buildUsernameField(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return BlocSelector<SetUpProfileScreenCubit, SetUpProfileScreenState,
        File?>(
      selector: (state) => switch (state) {
        SetUpProfileScreenInitial(:final photo) => photo,
        SetUpProfileScreenLoading(:final photo) => photo,
        SetUpProfileScreenError(:final photo) => photo,
        SetUpProfileScreenSuccess() => null,
      },
      builder: (context, photo) {
        return SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: photo == null
                    ? Image.asset(AppAssets.defaultPfp)
                    : Image.file(
                        photo,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: context.colorScheme.surface,
                    shape: const CircleBorder(),
                    shadowColor: context.colorScheme.shadow,
                    elevation: 3,
                  ),
                  onPressed: _showImagePicker,
                  icon: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showImagePicker() async {
    final result = await showModalActionSheet<bool>(
      context: context,
      cancelLabel: context.l10n.setUpProfileCancelAction,
      title: context.l10n.setUpProfileAddPicture,
      actions: [
        SheetAction(
          icon: Icons.camera_alt_outlined,
          label: context.l10n.setUpProfileUseCameraAction,
          key: true,
        ),
        SheetAction(
          icon: Icons.image_outlined,
          label: context.l10n.setUpProfileChooseFromGalleryAction,
          key: false,
        ),
      ],
    );

    if (result != null) _cubit.selectPhoto(result);
  }

  Widget _buildUsernameField() {
    return AppTextFormField(
      controller: _usernameController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.l10n.setUpProfileNameRequiredError;
        }

        if (value.contains(' ')) {
          return context.l10n.setUpProfileNameContainsSpaceError;
        }

        if (value.length < 3) {
          return context.l10n.setUpProfileNameTooShortError;
        }

        if (value.length > 12) {
          return context.l10n.setUpProfileNameTooLongError;
        }

        return null;
      },
      labelText: context.l10n.setUpProfileNameLabel,
      hintText: context.l10n.setUpProfileNameHint,
    );
  }

  Widget _buildBottomButton({required bool isLoading}) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ElevatedButton.icon(
          onPressed: isLoading
              ? null
              : () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _cubit.updateUserInfo(_usernameController.text);
                  }
                },
          label: Text(context.l10n.setUpProfileSetupButton),
          icon: const Icon(Icons.arrow_forward, size: 22),
          iconAlignment: IconAlignment.end,
        ),
      ),
    );
  }
}
