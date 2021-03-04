import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:services/blocs/bloc.dart';
import 'package:services/exceptions/UserRepositoryException.dart';
import 'package:services/repositories/UserRepository.dart';

main() {
  group("Unauthenticated", () {
    test("Doit retourner Unauthenticated si l'utilisateur n'est pas connecté",
        () async {
      // ARRANGE
      UserRepositoryMock userRepositoryMock = UserRepositoryMock();

      when(userRepositoryMock.isAuthenticated())
          .thenAnswer((_) => Future.value(false));

      // ignore: close_sinks
      final AuthenticationBloc authenticationBloc = AuthenticationBloc(
        userRepository: userRepositoryMock,
      );

      // ACT
      Stream<AuthenticationState> authenticatedState =
          authenticationBloc.mapEventToState(AppStarted());

      // ASSERT
      expect(await authenticatedState.first, Unauthenticated());
    });

    test(
        "Doit retourner Authenticated avec email et userID si l'utilisateur est connecté",
        () async {
      // ARRANGE
      UserRepositoryMock userRepositoryMock = UserRepositoryMock();

      when(userRepositoryMock.isAuthenticated())
          .thenAnswer((_) => Future.value(true));

      when(userRepositoryMock.getUserId())
          .thenAnswer((_) => Future.value('true'));

      when(userRepositoryMock.getUserEmail())
          .thenAnswer((_) => Future.value('john.doe@domain.tld'));

      // ignore: close_sinks
      final AuthenticationBloc authenticationBloc = AuthenticationBloc(
        userRepository: userRepositoryMock,
      );

      // ACT
      Stream<AuthenticationState> authenticatedState =
          authenticationBloc.mapEventToState(AppStarted());

      // ASSERT
      expect(
          await authenticatedState.first,
          Authenticated(
            userId: 'true',
            email: 'john.doe@domain.tld',
          ));
    });
  });

  group("SignInWithEmailAndPassword", () {
    test("Doit authentifier un utilisateur avec succes", () async {
      // ARRANGE
      UserRepositoryMock userRepositoryMock = UserRepositoryMock();

      when(userRepositoryMock.authencateWithEmail(
        'john.doe@domain.tld',
        '123456',
      )).thenAnswer(
        (_) => Future.value({
          'uid': '123456789',
          'email': 'john.doe@domain.tld',
        }),
      );

      // ignore: close_sinks
      final AuthenticationBloc authenticationBloc = AuthenticationBloc(
        userRepository: userRepositoryMock,
      );

      // ACT
      Stream<AuthenticationState> authenticatedState =
          authenticationBloc.mapEventToState(
        SignInWithEmailAndPassword(
          email: 'john.doe@domain.tld',
          password: '123456',
        ),
      );

      // ASSERT
      expect(
          await authenticatedState.first,
          Authenticated(
            userId: '123456789',
            email: 'john.doe@domain.tld',
          ));
    });

    test("Doit retouner une erreur avec de mauvais identifiant", () async {
      // ARRANGE
      UserRepositoryMock userRepositoryMock = UserRepositoryMock();

      when(userRepositoryMock.authencateWithEmail(
              'john.doe@domain.tld', '123456'))
          .thenThrow(
        UserRepositoryException(code: UserRepositoryException.BAD_CREDENTIALS),
      );

      // ignore: close_sinks
      final AuthenticationBloc authenticationBloc = AuthenticationBloc(
        userRepository: userRepositoryMock,
      );

      // ACT
      Stream<AuthenticationState> authenticatedState =
          authenticationBloc.mapEventToState(
        SignInWithEmailAndPassword(
          email: 'john.doe@domain.tld',
          password: '123456',
        ),
      );

      // ASSERT
      expect(
          await authenticatedState.first,
          AuthenticationErrors(
              errorCode: UserRepositoryException.BAD_CREDENTIALS));
    });
  });

  group("EmailProfileUpdated", () {
    test("Doit retourner un message de success (ProfileUpdated).", () async {
      // ARRANGE
      UserRepositoryMock userRepositoryMock = UserRepositoryMock();

      when(userRepositoryMock.updateEmail('john.doe@domain.tld'))
          .thenAnswer((_) => null);

      // ignore: close_sinks
      final AuthenticationBloc authenticationBloc = AuthenticationBloc(
        userRepository: userRepositoryMock,
      );

      // ACT
      Stream<AuthenticationState> authenticatedState = authenticationBloc
          .mapEventToState(UpdateEmailProfileEvent('john.doe@domain.tld'));

      // ASSERT

      expect(await authenticatedState.first, ProfileUpdated());
    });

    test(
        "Doit retourner une erreurs si le mail est déjà utiliser avec un autre compte (AuthenticationErrors).",
        () async {
      // ARRANGE
      UserRepositoryMock userRepositoryMock = UserRepositoryMock();

      when(userRepositoryMock.updateEmail('john.doe@domain.tld')).thenThrow(
          UserRepositoryException(
              code: UserRepositoryException.EMAIL_ALREADY_EXISTS));

      // ignore: close_sinks
      final AuthenticationBloc authenticationBloc = AuthenticationBloc(
        userRepository: userRepositoryMock,
      );

      // ACT
      Stream<AuthenticationState> authenticatedState = authenticationBloc
          .mapEventToState(UpdateEmailProfileEvent('john.doe@domain.tld'));

      // ASSERT
      expect(
        await authenticatedState.first,
        AuthenticationErrors(
            errorCode: UserRepositoryException.EMAIL_ALREADY_EXISTS),
      );
    });

    test(
        "Doit retourner une erreurs si le compte doit se reconnecter (AuthenticationErrors).",
        () async {
      // ARRANGE
      UserRepositoryMock userRepositoryMock = UserRepositoryMock();

      when(userRepositoryMock.updateEmail('john.doe@domain.tld')).thenThrow(
          UserRepositoryException(
              code: UserRepositoryException.REQUIRES_RECENT_LOGIN));

      // ignore: close_sinks
      final AuthenticationBloc authenticationBloc = AuthenticationBloc(
        userRepository: userRepositoryMock,
      );

      // ACT
      Stream<AuthenticationState> authenticatedState = authenticationBloc
          .mapEventToState(UpdateEmailProfileEvent('john.doe@domain.tld'));

      // ASSERT
      expect(
        await authenticatedState.first,
        AuthenticationErrors(
            errorCode: UserRepositoryException.REQUIRES_RECENT_LOGIN),
      );
    });
  });

  group("DeleteUserAccountEvent", () {
    test("Doit permettre de supprimer un compte avec succes", () async {
      // ARRANGE
      UserRepositoryMock userRepositoryMock = UserRepositoryMock();

      when(userRepositoryMock.deleteAccount()).thenAnswer((_) => null);

      // ignore: close_sinks
      final AuthenticationBloc authenticationBloc = AuthenticationBloc(
        userRepository: userRepositoryMock,
      );

      // ACT
      Stream<AuthenticationState> authenticatedState =
          authenticationBloc.mapEventToState(DeleteUserAccountEvent());

      // ASSERT
      expect(await authenticatedState.first, DeletedAccountState());

      verify(userRepositoryMock.deleteAccount());
    });

    test("Doit retourner une erreur quand une reconnexion est nécessaire",
        () async {
      // ARRANGE
      UserRepositoryMock userRepositoryMock = UserRepositoryMock();

      when(userRepositoryMock.deleteAccount())
          .thenThrow(UserRepositoryException(
        code: UserRepositoryException.REQUIRES_RECENT_LOGIN,
      ));

      // ignore: close_sinks
      final AuthenticationBloc authenticationBloc = AuthenticationBloc(
        userRepository: userRepositoryMock,
      );

      // ACT
      Stream<AuthenticationState> authenticatedState =
          authenticationBloc.mapEventToState(DeleteUserAccountEvent());

      // ASSERT
      expect(
        await authenticatedState.first,
        AuthenticationErrors(
          errorCode: UserRepositoryException.REQUIRES_RECENT_LOGIN,
        ),
      );
    });
  });

  group("SignOut", () {
    test("Doit retourner Unauthenticated", () async {
      // ARRANGE
      UserRepositoryMock userRepositoryMock = UserRepositoryMock();

      when(userRepositoryMock.signOut()).thenAnswer((_) => Future.value());

      // ignore: close_sinks
      final AuthenticationBloc authenticationBloc = AuthenticationBloc(
        userRepository: userRepositoryMock,
      );

      // ACT
      Stream<AuthenticationState> authenticatedState =
          authenticationBloc.mapEventToState(SignOut());

      // ASSERT
      expect(await authenticatedState.first, Unauthenticated());
    });
  });
}

class UserRepositoryMock extends Mock implements UserRepository {}
