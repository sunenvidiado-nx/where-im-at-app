import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';

@injectable
class DefaultProfilePictureService {
  const DefaultProfilePictureService(this._storage);

  final FirebaseStorage _storage;

  Future<String> getUrl() async {
    final storageRef = _storage.ref();
    final defaultPfpRef = storageRef.child('default_pfp.png');
    return await defaultPfpRef.getDownloadURL();
  }
}
