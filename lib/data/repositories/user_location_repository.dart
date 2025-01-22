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

  /// Stream locations of users that are broadcasting their location.
  Stream<List<UserLocation>> streamUserLocations() {
    return _firestore
        .collection(_collectionPath)
        .where('is_broadcasting', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map(UserLocation.fromFirestore).toList());
  }

  /// Creates or updates a user's location in Firestore.
  Future<void> createOrUpdate(UserLocation userLocation) async {
    await _firestore.collection(_collectionPath).doc(userLocation.id).set(
          userLocation.toFirestoreMap(),
          SetOptions(merge: true),
        );
  }
}
