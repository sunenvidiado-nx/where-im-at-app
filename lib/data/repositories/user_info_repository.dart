import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/domain/models/user_info.dart';

@injectable
class UserInfoRepository {
  const UserInfoRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const _collectionPath = 'user_info';

  Future<UserInfo> getUserInfo(String userId) async {
    return _firestore
        .collection(_collectionPath)
        .doc(userId)
        .get()
        .then(UserInfo.fromFirestore);
  }

  Future<void> createOrUpdate(UserInfo userInfo) async {
    await _firestore.collection(_collectionPath).doc(userInfo.id).set(
          userInfo.toFirestoreMap(),
          SetOptions(merge: true),
        );
  }
}
