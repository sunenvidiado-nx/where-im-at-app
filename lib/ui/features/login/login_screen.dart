import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:where_im_at/app/router/router_config.dart';
import 'package:where_im_at/app/themes/app_assets.dart';
import 'package:where_im_at/ui/common_widgets/snackbars/app_snackbar.dart';
import 'package:where_im_at/ui/common_widgets/textfields/app_text_form_field.dart';
import 'package:where_im_at/ui/features/login/login_screen_cubit.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final _emailController = TextEditingController();
  late final _passwordController = TextEditingController();
  late final _cubit = context.read<LoginScreenCubit>();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginScreenCubit, LoginScreenState>(
      listener: _hadnleStateChange,
      builder: (context, state) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildForm(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: _buildBottomNavigationBar(
            isLoading: state is LoginScreenLoading,
          ),
        ),
      ),
    );
  }

  void _hadnleStateChange(BuildContext context, LoginScreenState state) {
    if (state is LoginScreenError) {
      context.showSnackbar(state.errorMessage, type: AppSnackbarType.error);
    }

    if (state is LoginScreenSuccess) {
      context.go(Routes.home);
    }
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: SvgPicture.asset(AppAssets.mainLogo, height: 42),
        ),
        const SizedBox(height: 24),
        Text(
          context.l10n.loginTitle,
          style: context.primaryTextTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.loginSubtitle,
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colorScheme.outline.withAlpha(160),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextFormField(
          controller: _emailController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.l10n.emailRequiredError;
            }

            if (!value.contains('@')) {
              return context.l10n.emailInvalidError;
            }

            return null;
          },
          hintText: context.l10n.emailHint,
          labelText: context.l10n.emailLabel,
        ),
        const SizedBox(height: 16),
        AppTextFormField(
          controller: _passwordController,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.l10n.passwordRequiredError;
            }

            return null;
          },
          hintText: context.l10n.passwordHint,
          labelText: context.l10n.passwordLabel,
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar({required bool isLoading}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton.icon(
            onPressed: isLoading
                ? null
                : () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _cubit.login(
                        _emailController.text,
                        _passwordController.text,
                      );
                    }
                  },
            label: Text(context.l10n.signInButton),
            icon: const Icon(Icons.arrow_forward, size: 22),
            iconAlignment: IconAlignment.end,
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: context.l10n.noAccountText,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.normal,
                ),
              ),
              TextSpan(
                text: context.l10n.registerNowText,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => context.pushNamed(Routes.register),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
