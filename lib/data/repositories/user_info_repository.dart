import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/domain/models/user_info.dart';

@injectable
class UserInfoRepository {
  const UserInfoRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const _collectionPath = 'user_info';

  Future<UserInfo?> getUserInfo(String userId) async {
    final doc = await _firestore.collection(_collectionPath).doc(userId).get();
    return doc.exists ? UserInfo.fromFirestore(doc) : null;
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
