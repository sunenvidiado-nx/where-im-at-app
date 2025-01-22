import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/domain/models/user_info.dart';

@injectable
class UserInfoRepository {
  UserInfoRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const _collectionPath = 'user_info';

  final _cache = <String, UserInfo>{};

  Future<UserInfo?> getUserInfo(String userId, {bool useCache = true}) async {
    if (useCache && _cache.containsKey(userId)) {
      return _cache[userId];
    }

    final userInfo = await _firestore
        .collection(_collectionPath)
        .doc(userId)
        .get()
        .then((doc) => doc.exists ? UserInfo.fromFirestore(doc) : null);

    if (userInfo != null) _cache[userId] = userInfo;

    return userInfo;
  }

  Future<void> createOrUpdate(UserInfo userInfo) async {
    await _firestore.collection(_collectionPath).doc(userInfo.id).set(
          userInfo.toFirestoreMap(),
          SetOptions(merge: true),
        );
  }

  Future<String> uploadUserPhoto(String userId, File photo) async {
    final ref = _storage.ref(_collectionPath).child(userId);
    await ref.putFile(photo);
    return await ref.getDownloadURL();
  }
}
