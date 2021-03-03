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
  Future<Map<String, String>> authencateWithEmail(
    String email,
    String password,
  ) async {
    Map<String, String> data = {};

    try {
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      data['uid'] = userCredential.user.uid;
      data['email'] = userCredential.user.email;
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

    return data;
  }

  @override
  Future<String> getUserId() async {
    return firebaseAuth.currentUser.uid;
  }

  @override
  Future<String> getUserEmail() async {
    return firebaseAuth.currentUser.email;
  }

  @override
  Future<void> updateEmail(String email) async {
    try {
      await firebaseAuth.currentUser.updateEmail(email);
    } on FirebaseAuthException catch (e) {
      print(e.code);

      if (e.code == 'account-exists-with-different-credential') {
        throw UserRepositoryException(
            code: UserRepositoryException.EMAIL_ALREADY_EXISTS);
      }

      if (e.code == 'requires-recent-login') {
        throw UserRepositoryException(
            code: UserRepositoryException.REQUIRES_RECENT_LOGIN);
      }

      if (e.code == 'invalid-email') {
        throw UserRepositoryException(
            code: UserRepositoryException.INVALID_EMAIL);
      }
    }
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
