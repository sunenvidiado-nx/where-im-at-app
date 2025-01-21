import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:latlong2/latlong.dart';

part 'user_location.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class UserLocation with UserLocationMappable {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.isBroadcasting,
    required this.updatedAt,
    this.id,
  });

  /// Factory for creating a [UserLocation] from a Firestore document.
  factory UserLocation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserLocation(
      latitude: data['latitude'],
      longitude: data['longitude'],
      isBroadcasting: data['is_broadcasting'],
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      id: doc.id,
    );
  }

  final num latitude;
  final num longitude;
  final bool isBroadcasting;
  final DateTime updatedAt;

  /// For convenience, this should be set to the coresponding user's ID.
  final String? id;

  LatLng get latLong => LatLng(latitude.toDouble(), longitude.toDouble());

  /// Converts this [UserLocation] to a map suitable for Firestore storage.
  ///
  /// The `id` property is not included in the map as it is set
  /// via `doc(id)` when writing to Firestore.
  Map<String, dynamic> toFirestoreMap() {
    return (toMap()..remove('id'))
      ..['updated_at'] = Timestamp.fromDate(updatedAt.toUtc());
  }
}
