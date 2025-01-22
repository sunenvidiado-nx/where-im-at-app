import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:where_im_at/app/router/routes.dart';
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
      listener: _handleSatateChange,
      builder: (context, state) {
        return Scaffold(
          body: Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                _buildTitle(context),
                _buildProfileContent(context),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomButton(context),
        );
      },
    );
  }

  void _handleSatateChange(
    BuildContext context,
    SetUpProfileScreenState state,
  ) {
    if (state.errorMessage != null) {
      context.showSnackbar(state.errorMessage!, type: AppSnackbarType.error);
    }
  }

  Widget _buildTitle(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 72, 24, 0),
        child: Center(
          child: Text(
            context.l10n.setUpProfileTitle,
            style: context.primaryTextTheme.displaySmall,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.07),
            _buildProfileAvatar(),
            SizedBox(height: screenHeight * 0.06),
            _buildUsernameField(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return BlocSelector<SetUpProfileScreenCubit, SetUpProfileScreenState,
        File?>(
      selector: (state) => state.photo,
      builder: (context, photo) {
        return Stack(
          children: [
            CircleAvatar(
              radius: 72,
              child: ClipOval(
                child: photo == null
                    ? Image.asset(AppAssets.defaultPfp)
                    : Image.file(
                        photo,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
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
          return context.l10n.setUpProfileUsernameRequiredError;
        }

        if (value.contains(' ')) {
          return context.l10n.setUpProfileUsernameContainsSpaceError;
        }

        if (value.length < 3) {
          return context.l10n.setUpProfileUsernameTooShortError;
        }

        if (value.length > 16) {
          return context.l10n.setUpProfileUsernameTooLongError;
        }

        return null;
      },
      labelText: context.l10n.setUpProfileUsernameLabel,
      hintText: context.l10n.setUpProfileUsernameHint,
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: BlocSelector<SetUpProfileScreenCubit, SetUpProfileScreenState,
            bool>(
          selector: (state) => state.isLoading,
          builder: (context, isLoading) {
            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        await _cubit.updateUserInfo(_usernameController.text);

                        if (_cubit.state.didSetUpProfile) {
                          // ignore: use_build_context_synchronously
                          context.go(Routes.home);
                        }
                      }
                    },
              child: Text(context.l10n.setUpProfileSetupButton),
            );
          },
        ),
      ),
    );
  }
}
