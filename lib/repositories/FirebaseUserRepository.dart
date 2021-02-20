import 'package:firebase_auth/firebase_auth.dart';
import 'package:services/repositories/UserRepository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseAuth firebaseAuth;

  const FirebaseUserRepository({
    this.firebaseAuth,
  });

  @override
  Future<bool> isAuthenticated() async {
    return firebaseAuth.currentUser != null;
  }

  @override
  Future<void> authenticate() {
    // TODO: implement authenticate
    throw UnimplementedError();
  }

  @override
  Future<String> getUserId() {
    // TODO: implement getUserId
    throw UnimplementedError();
  }
}
