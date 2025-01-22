import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';

class NoLocationServicesScreen extends StatelessWidget {
  const NoLocationServicesScreen({super.key});

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
                  context.l10n.locationServicesDisabledTitle,
                  style: context.primaryTextTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: context.textTheme.titleMedium,
                    children: [
                      TextSpan(
                        text: context.l10n.locationServicesDisabledMessage,
                      ),
                      TextSpan(
                        text: context.l10n.locationServicesDisabledSettings,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            if (await canLaunchUrl(
                              Uri.parse('app-settings:'),
                            )) {
                              await launchUrl(Uri.parse('app-settings:'));
                            }
                          },
                      ),
                      TextSpan(
                        text: context.l10n.locationServicesDisabledAndEnable,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                '(￣_￣)・・・', // TODO Move to l10n? idk what to do here
                style: context.textTheme.displaySmall?.copyWith(
                  color: context.colorScheme.shadow.withAlpha(40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
