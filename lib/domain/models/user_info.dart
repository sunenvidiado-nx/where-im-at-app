import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'user_info.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class UserInfo with UserInfoMappable {
  const UserInfo({
    required this.username,
    required this.photoUrl,
    required this.updatedAt,
    this.id,
  });

  factory UserInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserInfo(
      username: data['username'],
      photoUrl: data['photo_url'],
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      id: doc.id,
    );
  }

  final String username;
  final String photoUrl;
  final DateTime updatedAt;

  /// For convenience, this should be set to the coresponding user's ID.
  final String? id;

  Map<String, dynamic> toFirestoreMap() {
    return (toMap()..remove('id'))
      ..['updated_at'] = Timestamp.fromDate(updatedAt.toUtc());
  }
}
