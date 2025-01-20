import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/domain/models/user_location.dart';

@injectable
class UserLocationRepository {
  const UserLocationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const _collectionPath = 'user_locations';

  /// Stream locations of users that are broadcasting their location.
  Stream<List<UserLocation>> streamUserLocations() {
    return _firestore
        .collection(_collectionPath)
        .where('is_broadcasting', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserLocation.fromFirestore(doc))
              .toList(),
        )
        .where((locations) => locations.isNotEmpty);
  }

  /// Creates or updates a user's location in Firestore.
  Future<void> createOrUpdate(UserLocation userLocation) async {
    await _firestore.collection(_collectionPath).doc(userLocation.id).set(
          userLocation.toFirestoreMap(),
          SetOptions(merge: true),
        );
  }
}
