import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/config/dependency_injection/di_keys.dart';
import 'package:where_im_at/config/dependency_injection/di_setup.config.dart';
import 'package:where_im_at/utils/extensions/int_extensions.dart';

@InjectableInit()
Future<void> configureDependencies() async => GetIt.I.init();

@module
abstract class DiModules {
  @singleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @singleton
  FlutterSecureStorage get secureStorage {
    return const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
  }

  @singleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @singleton
  FirebaseStorage get firebaseStorage => FirebaseStorage.instance;

  @Named(DiKeys.mapCacheManager)
  CacheManager get mapCacheManager {
    // Generate keys here: http://bit.ly/random-strings-generator
    const key = 'Cqt2k37G4UFX';
    return CacheManager(
      Config(
        key,
        stalePeriod: 60.days,
        maxNrOfCacheObjects: 10000,
        repo: JsonCacheInfoRepository(databaseName: key),
        fileService: HttpFileService(),
      ),
    );
  }
}
