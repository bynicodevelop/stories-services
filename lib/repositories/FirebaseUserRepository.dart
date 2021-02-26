import 'package:firebase_auth/firebase_auth.dart';
import 'package:services/exceptions/UserRepositoryException.dart';
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
  Future<String> authencateWithEmail(String email, String password) async {
    String uid;

    try {
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      uid = userCredential.user.uid;
    } on FirebaseAuthException catch (e) {
      print('e.code: ${e.code}');

      if (e.code == 'wrong-password' || e.code == 'user-not-found') {
        throw UserRepositoryException(
          code: UserRepositoryException.BAD_CREDENTIALS,
        );
      }

      if (e.code == 'too-many-requests') {
        throw UserRepositoryException(
          code: UserRepositoryException.TOO_MANY_REQUESTS,
        );
      }
    }

    return uid;
  }

  @override
  Future<String> getUserId() async {
    return firebaseAuth.currentUser.uid;
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
