import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// Provides a convenient way to access [AppLocalizations] without requiring a [BuildContext].
///
/// This utility leverages [GoRouter], obtained via GetIt, to retrieve the current [BuildContext].
AppLocalizations get l10n {
  return AppLocalizations.of(
    GetIt.I<GoRouter>().routerDelegate.navigatorKey.currentContext!,
  )!;
}
