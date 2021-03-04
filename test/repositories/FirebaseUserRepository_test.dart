import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:services/exceptions/UserRepositoryException.dart';
import 'package:services/repositories/FirebaseUserRepository.dart';

main() {
  group("isAuthenticated", () {
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
  });

  group("authencateEmail", () {
    test("Doit retouner une erreur si l'email ne correspond à aucun compte",
        () async {
      // ARRANGE
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();

      when(firebaseAuthMock.signInWithEmailAndPassword(
        email: 'john.doe@domain.tld',
        password: '123456',
      )).thenThrow(FirebaseAuthException(
        code: 'user-not-found',
        message: null,
      ));

      FirebaseUserRepository firebaseUserRepository = FirebaseUserRepository(
        firebaseAuth: firebaseAuthMock,
      );

      // ACT
      // ASSERT
      expect(
        () async => await firebaseUserRepository.authencateWithEmail(
          'john.doe@domain.tld',
          '123456',
        ),
        throwsA(
          allOf(
            isInstanceOf<UserRepositoryException>(),
            predicate((f) => f.code == UserRepositoryException.BAD_CREDENTIALS),
          ),
        ),
      );
    });

    test("Doit retouner une erreur si le mot de passe n'est pas correct",
        () async {
      // ARRANGE
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();

      when(firebaseAuthMock.signInWithEmailAndPassword(
        email: 'john.doe@domain.tld',
        password: '123456',
      )).thenThrow(FirebaseAuthException(
        code: 'wrong-password',
        message: null,
      ));

      FirebaseUserRepository firebaseUserRepository = FirebaseUserRepository(
        firebaseAuth: firebaseAuthMock,
      );

      // ACT
      // ASSERT
      expect(
        () async => await firebaseUserRepository.authencateWithEmail(
            'john.doe@domain.tld', '123456'),
        throwsA(
          allOf(
            isInstanceOf<UserRepositoryException>(),
            predicate((f) => f.code == UserRepositoryException.BAD_CREDENTIALS),
          ),
        ),
      );
    });

    test(
        "Doit retouner une erreur trop de tentatives de connection ont été effectués",
        () async {
      // ARRANGE
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();

      when(firebaseAuthMock.signInWithEmailAndPassword(
        email: 'john.doe@domain.tld',
        password: '123456',
      )).thenThrow(FirebaseAuthException(
        code: 'too-many-requests',
        message: null,
      ));

      FirebaseUserRepository firebaseUserRepository = FirebaseUserRepository(
        firebaseAuth: firebaseAuthMock,
      );

      // ACT
      // ASSERT
      expect(
        () async => await firebaseUserRepository.authencateWithEmail(
          'john.doe@domain.tld',
          '123456',
        ),
        throwsA(
          allOf(
            isInstanceOf<UserRepositoryException>(),
            predicate(
                (f) => f.code == UserRepositoryException.TOO_MANY_REQUESTS),
          ),
        ),
      );
    });

    test("Doit retouner un success", () async {
      // ARRANGE
      FirebaseUserMock firebaseUserMock = FirebaseUserMock();
      UserCredentialMock userCredentialMock = UserCredentialMock();
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();

      when(firebaseUserMock.uid).thenReturn('123456789');
      when(firebaseUserMock.email).thenReturn('john.doe@domain.tld');

      when(userCredentialMock.user).thenReturn(firebaseUserMock);

      when(firebaseAuthMock.signInWithEmailAndPassword(
        email: 'john.doe@domain.tld',
        password: '123456',
      )).thenAnswer((_) => Future.value(userCredentialMock));

      FirebaseUserRepository firebaseUserRepository = FirebaseUserRepository(
        firebaseAuth: firebaseAuthMock,
      );

      // ACT
      // ASSERT
      final Map<String, String> result =
          await firebaseUserRepository.authencateWithEmail(
        'john.doe@domain.tld',
        '123456',
      );

      expect(result['uid'], '123456789');
      expect(result['email'], 'john.doe@domain.tld');
    });
  });

  group("signOut", () {
    test("Doit appeler la méthode de déconnextion de firebase", () async {
      // ARRANGE
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();

      FirebaseUserRepository firebaseUserRepository = FirebaseUserRepository(
        firebaseAuth: firebaseAuthMock,
      );

      // ACT
      await firebaseUserRepository.signOut();

      // ASSERT
      verify(firebaseAuthMock.signOut());
    });
  });

  group("getUserId", () {
    test("Doit appeler les proporiété pour avoir l'uid de l'utilisateur",
        () async {
      // ARRANGE
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
      FirebaseUserMock userMock = FirebaseUserMock();

      when(userMock.uid).thenReturn('123456789');
      when(userMock.email).thenReturn('john.doe@domain.tld');

      when(firebaseAuthMock.currentUser).thenReturn(userMock);

      FirebaseUserRepository firebaseUserRepository = FirebaseUserRepository(
        firebaseAuth: firebaseAuthMock,
      );

      // ACT
      String uid = await firebaseUserRepository.getUserId();

      // ASSERT
      expect(uid, "123456789");
    });
  });

  group("getUserEmail", () {
    test("Doit appeler les proporiété pour avoir l'email de l'utilisateur",
        () async {
      // ARRANGE
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
      FirebaseUserMock userMock = FirebaseUserMock();

      when(userMock.email).thenReturn('john.doe@domain.tld');

      when(firebaseAuthMock.currentUser).thenReturn(userMock);

      FirebaseUserRepository firebaseUserRepository = FirebaseUserRepository(
        firebaseAuth: firebaseAuthMock,
      );

      // ACT
      String email = await firebaseUserRepository.getUserEmail();

      // ASSERT
      expect(email, "john.doe@domain.tld");
    });
  });

  group("updateEmail", () {
    test("Doit mettre à jour l'email de l'utilisateur", () async {
      // ARRANGE
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
      FirebaseUserMock userMock = FirebaseUserMock();

      when(userMock.updateEmail('john.doe@domain.tld')).thenReturn(null);

      when(firebaseAuthMock.currentUser).thenReturn(userMock);

      FirebaseUserRepository firebaseUserRepository = FirebaseUserRepository(
        firebaseAuth: firebaseAuthMock,
      );

      // ACT
      await firebaseUserRepository.updateEmail('john.doe@domain.tld');

      // ASSERT
      verify(userMock.updateEmail('john.doe@domain.tld'));
    });

    test("Doit soulever une exception si l'email existe déjà", () async {
      // ARRANGE
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
      FirebaseUserMock userMock = FirebaseUserMock();

      when(userMock.updateEmail('john.doe@domain.tld'))
          .thenThrow(FirebaseAuthException(
        code: 'account-exists-with-different-credential',
        message: null,
      ));

      when(firebaseAuthMock.currentUser).thenReturn(userMock);

      FirebaseUserRepository firebaseUserRepository = FirebaseUserRepository(
        firebaseAuth: firebaseAuthMock,
      );

      // ACT
      // ASSERT
      expect(
        () async => await firebaseUserRepository.updateEmail(
          'john.doe@domain.tld',
        ),
        throwsA(
          allOf(
            isInstanceOf<UserRepositoryException>(),
            predicate(
                (f) => f.code == UserRepositoryException.EMAIL_ALREADY_EXISTS),
          ),
        ),
      );
    });

    test(
        "Doit soulever une exception si l'utilisater essaye de modifier son email sans être connecté",
        () async {
      // ARRANGE
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
      FirebaseUserMock userMock = FirebaseUserMock();

      when(userMock.updateEmail('john.doe@domain.tld'))
          .thenThrow(FirebaseAuthException(
        code: 'requires-recent-login',
        message: null,
      ));

      when(firebaseAuthMock.currentUser).thenReturn(userMock);

      FirebaseUserRepository firebaseUserRepository = FirebaseUserRepository(
        firebaseAuth: firebaseAuthMock,
      );

      // ACT
      // ASSERT
      expect(
        () async => await firebaseUserRepository.updateEmail(
          'john.doe@domain.tld',
        ),
        throwsA(
          allOf(
            isInstanceOf<UserRepositoryException>(),
            predicate(
                (f) => f.code == UserRepositoryException.REQUIRES_RECENT_LOGIN),
          ),
        ),
      );
    });

    test(
        "Doit soulever une exception si l'utilisater essaye d'email un email invalide",
        () async {
      // ARRANGE
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
      FirebaseUserMock userMock = FirebaseUserMock();

      when(userMock.updateEmail('john.doe@domain.tld'))
          .thenThrow(FirebaseAuthException(
        code: 'invalid-email',
        message: null,
      ));

      when(firebaseAuthMock.currentUser).thenReturn(userMock);

      FirebaseUserRepository firebaseUserRepository = FirebaseUserRepository(
        firebaseAuth: firebaseAuthMock,
      );

      // ACT
      // ASSERT
      expect(
        () async => await firebaseUserRepository.updateEmail(
          'john.doe@domain.tld',
        ),
        throwsA(
          allOf(
            isInstanceOf<UserRepositoryException>(),
            predicate((f) => f.code == UserRepositoryException.INVALID_EMAIL),
          ),
        ),
      );
    });
  });

  group("deleteAccount", () {
    test("Doit permettre la suppression d'un compte avec success", () async {
      // ARRANGE
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
      FirebaseUserMock userMock = FirebaseUserMock();

      when(firebaseAuthMock.currentUser).thenReturn(userMock);

      FirebaseUserRepository firebaseUserRepository = FirebaseUserRepository(
        firebaseAuth: firebaseAuthMock,
      );

      // ACT
      await firebaseUserRepository.deleteAccount();

      // ASSERT
      verify(userMock.delete());
    });

    test("Doit soulever une erreur quand une authentification est requis",
        () async {
      // ARRANGE
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
      FirebaseUserMock userMock = FirebaseUserMock();

      when(userMock.delete()).thenThrow(FirebaseAuthException(
        code: 'requires-recent-login',
        message: null,
      ));

      when(firebaseAuthMock.currentUser).thenReturn(userMock);

      FirebaseUserRepository firebaseUserRepository = FirebaseUserRepository(
        firebaseAuth: firebaseAuthMock,
      );

      // ACT
      // ASSERT
      expect(
        () async => await firebaseUserRepository.deleteAccount(),
        throwsA(
          allOf(
            isInstanceOf<UserRepositoryException>(),
            predicate(
                (f) => f.code == UserRepositoryException.REQUIRES_RECENT_LOGIN),
          ),
        ),
      );
    });
  });
}

class FirebaseAuthMock extends Mock implements FirebaseAuth {}

class UserCredentialMock extends Mock implements UserCredential {}

class FirebaseUserMock extends Mock implements User {}
