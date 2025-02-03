import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:where_im_at/utils/extensions/int_extensions.dart';

abstract class BackgroundLocationService {
  static Future<void> initialize() async {
    await GetIt.I<FlutterBackgroundService>().configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: true,
        onStart: onStart,
        isForegroundMode: false,
        autoStartOnBoot: true,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    var shouldStop = false;

    service.on('stopService').listen((_) async {
      await service.stopSelf();
      shouldStop = true;
    });

    if (shouldStop) return;

    Timer.periodic(1.minutes, (timer) async {
      try {
        final userId = GetIt.I<FirebaseAuth>().currentUser!.uid;
        final locationIsBroadcasted = await GetIt.I<FirebaseFirestore>()
            .collection('user_locations')
            .doc(userId)
            .get()
            .then((doc) => doc.data()?['is_broadcasting'] ?? false);

        // If user isn't broadcasting their location and this runs for
        // some reason, then we stop this service
        if (!locationIsBroadcasted) {
          service.stopSelf();
          timer.cancel();
          return;
        }

        // If user is broadcasting, then we periodically update the user
        // location details in firebase
        final location = await Geolocator.getCurrentPosition();
        final userLocationDetails = {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'updated_at': Timestamp.now(),
        };

        await GetIt.I<FirebaseFirestore>()
            .collection('user_locations')
            .doc(userId)
            .set(userLocationDetails, SetOptions(merge: true));

        if (kDebugMode) {
          await GetIt.I<FlutterLocalNotificationsPlugin>().show(
            0,
            'Location Updated',
            'Latitude: ${location.latitude}, Longitude: ${location.longitude}',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'location_channel',
                'Location Updates',
                importance: Importance.low,
              ),
              iOS: DarwinNotificationDetails(),
            ),
          );
        }
      } catch (e) {
        // TODO Handle this gracefully, for now do nothing :D
        service.stopSelf();
        timer.cancel();
      }
    });
  }
}
