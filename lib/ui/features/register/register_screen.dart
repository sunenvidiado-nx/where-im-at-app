import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';

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
                  'We don\'t accept new users at the moment.',
                  style: context.primaryTextTheme.displaySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'But stay tuned for future updates!',
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                '┐(￣∀￣)┌',
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
            child: const Text('Back to Sign in'),
          ),
        ),
      ),
    );
  }
}
