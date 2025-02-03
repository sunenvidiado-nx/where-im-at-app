import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/domain/models/user_location.dart';

@injectable
class UserLocationRepository {
  const UserLocationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const _collectionPath = 'user_locations';

  Future<UserLocation?> getByUserId(String userId) async {
    final doc = await _firestore.collection(_collectionPath).doc(userId).get();
    return doc.exists ? UserLocation.fromFirestore(doc) : null;
  }

  /// Returns a stream of user locations for users who are currently broadcasting
  /// their location
  Stream<List<UserLocation>> streamUserLocations() {
    return _firestore
        .collection(_collectionPath)
        .where('is_broadcasting', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map(UserLocation.fromFirestore).toList());
  }

  /// Returns a list of user locations for users who are currently broadcasting
  /// their location
  Future<List<UserLocation>> getUserLocations() async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('is_broadcasting', isEqualTo: true)
        .get();

    return snapshot.docs.map(UserLocation.fromFirestore).toList();
  }

  Future<void> createOrUpdate(UserLocation userLocation) async {
    final docRef = _firestore.collection(_collectionPath).doc(userLocation.id);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef.update(userLocation.toFirestoreMap());
    } else {
      await docRef.set(userLocation.toFirestoreMap());
    }
  }
}
