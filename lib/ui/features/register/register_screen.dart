import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';

// TODO Implement this

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.list(
              children: [
                const SizedBox(height: 72),
                Text(
                  context.l10n.registerNotAcceptingUsersTitle,
                  style: context.primaryTextTheme.displaySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.registerNotAcceptingUsersSubtitle,
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                '┐(￣∀￣)┌', // TODO Move to l10n? idk what to do here
                style: context.textTheme.displayMedium?.copyWith(
                  color: context.colorScheme.shadow.withAlpha(40),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton(
            onPressed: context.pop,
            child: Text(context.l10n.registerBackToSignIn),
          ),
        ),
      ),
    );
  }
}
