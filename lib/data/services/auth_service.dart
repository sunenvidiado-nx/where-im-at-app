import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/config/dependency_injection/di_keys.dart';

@injectable
class AuthService {
  const AuthService(
    this._firebaseAuth,
    @Named(DiKeys.mapCacheManager) this._mapCacheManager,
  );

  final FirebaseAuth _firebaseAuth;
  final CacheManager _mapCacheManager;

  User? get currentUser => _firebaseAuth.currentUser;

  bool get isLoggedIn => currentUser != null;

  Future<void> signInWithEmail(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await Future.wait<void>([
      _mapCacheManager.emptyCache(),
      _firebaseAuth.signOut(),
    ]);
  }
}
