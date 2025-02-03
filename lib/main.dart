import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:where_im_at/app/app.dart';
import 'package:where_im_at/app/themes/app_colors.dart';
import 'package:where_im_at/config/dependency_injection/di_setup.dart';
import 'package:where_im_at/data/services/background_location_service.dart';
import 'package:where_im_at/data/services/location_service.dart';
import 'package:where_im_at/firebase_options.dart';

void main() {
  runZoned(() async {
    WidgetsFlutterBinding.ensureInitialized();

    GoRouter.optionURLReflectsImperativeAPIs = true;

    await _configureFirebase(); // Must be called first before other initialization
    await configureDependencies();
    await _configureLocationService();
    await _configureBackgroundLocationService();
    await _configureLocalNotifications();

    _configureNavigationAndStatusBarColors();

    runApp(const App());
  });
}

Future<void> _configureFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) return;

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<void> _configureLocationService() async {
  await GetIt.I<LocationService>().initialize();
}

void _configureNavigationAndStatusBarColors() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.lightBackground.withAlpha(1),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

Future<void> _configureBackgroundLocationService() async {
  await BackgroundLocationService.initialize();
}

Future<void> _configureLocalNotifications() async {
  /// We only configure local notifications in debug mode for testing purposes
  if (!kDebugMode) return;

  await GetIt.I<FlutterLocalNotificationsPlugin>().initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
}
