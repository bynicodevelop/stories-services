import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:services/repositories/FirebaseUserRepository.dart';

main() {
  test("Doit retrouner true", () async {
    // ARRANGE
    FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();

    when(firebaseAuthMock.currentUser).thenReturn(FirebaseUserMock());

    FirebaseUserRepository firebaseUserRepository = FirebaseUserRepository(
      firebaseAuth: firebaseAuthMock,
    );

    // ACT
    final isAuthenticated = await firebaseUserRepository.isAuthenticated();

    // ASSERT
    expect(isAuthenticated, true);
  });

  test("Doit retrouner false", () async {
    // ARRANGE
    FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();

    when(firebaseAuthMock.currentUser).thenReturn(null);

    FirebaseUserRepository firebaseUserRepository = FirebaseUserRepository(
      firebaseAuth: firebaseAuthMock,
    );

    // ACT
    final isAuthenticated = await firebaseUserRepository.isAuthenticated();

    // ASSERT
    expect(isAuthenticated, false);
  });
}

class FirebaseAuthMock extends Mock implements FirebaseAuth {}

class FirebaseUserMock extends Mock implements User {}
