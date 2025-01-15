import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';

enum AppSnackbarType { success, error }

abstract class AppSnackbar {
  static show(
    BuildContext context, {
    required String message,
    AppSnackbarType type = AppSnackbarType.success,
  }) {
    showToastWidget(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.shadow.withAlpha(50),
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Text(
            message,
            style: context.textTheme.bodySmall,
          ),
        ),
      ),
      context: context,
      dismissOtherToast: true,
      position: const StyledToastPosition(align: Alignment.bottomCenter),
      animation: StyledToastAnimation.fade,
      reverseAnimation: StyledToastAnimation.fade,
      duration: const Duration(seconds: 4),
      animDuration: const Duration(milliseconds: 200),
    );
  }
}

extension AppSnackbarExtension on BuildContext {
  void showSnackbar(
    String message, {
    AppSnackbarType type = AppSnackbarType.success,
  }) {
    AppSnackbar.show(this, message: message, type: type);
  }

  void showErrorSnackbar([String? message]) {
    AppSnackbar.show(
      this,
      message: message ?? l10n.longGenericError,
      type: AppSnackbarType.error,
    );
  }
}
