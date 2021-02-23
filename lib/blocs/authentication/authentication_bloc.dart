import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:services/blocs/bloc.dart';
import 'package:services/repositories/UserRepository.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(Unauthenticated());

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    print('AuthenticationBloc - mapEventToState: $event');

    if (event is AppStarted) {
      final bool isAuthenticated = await _userRepository.isAuthenticated();

      if (!isAuthenticated) {}

      yield Unauthenticated();
    }
  }
}
