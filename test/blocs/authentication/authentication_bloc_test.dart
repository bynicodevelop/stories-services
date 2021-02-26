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

    test("Doit retourner Authenticated si l'utilisateur est pas connecté",
        () async {
      // ARRANGE
      UserRepositoryMock userRepositoryMock = UserRepositoryMock();

      when(userRepositoryMock.isAuthenticated())
          .thenAnswer((_) => Future.value(true));

      when(userRepositoryMock.getUserId())
          .thenAnswer((_) => Future.value('true'));

      // ignore: close_sinks
      final AuthenticationBloc authenticationBloc = AuthenticationBloc(
        userRepository: userRepositoryMock,
      );

      // ACT
      Stream<AuthenticationState> authenticatedState =
          authenticationBloc.mapEventToState(AppStarted());

      // ASSERT
      expect(await authenticatedState.first, Authenticated('true'));
    });
  });

  group("SignInWithEmailAndPassword", () {
    test("Doit authentifier un utilisateur avec succes", () async {
      // ARRANGE
      UserRepositoryMock userRepositoryMock = UserRepositoryMock();

      when(userRepositoryMock.authencateWithEmail(
              'john.doe@domain.tld', '123456'))
          .thenAnswer((_) => Future.value('123456789'));

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
      expect(await authenticatedState.first, Authenticated('123456789'));
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
