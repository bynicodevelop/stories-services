library services;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services/blocs/authentication/authentication_bloc.dart';
import 'package:services/blocs/bloc.dart';
import 'package:services/repositories/FirebaseUserRepository.dart';

class Services extends StatelessWidget {
  final Widget child;

  Services({
    Key key,
    this.child,
  }) : super(key: key) {
    print('Servives loaded...');
    Bloc.observer = SimpleBlocObserver();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox.shrink();
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthenticationBloc>(
              create: (context) => AuthenticationBloc(
                userRepository: FirebaseUserRepository(
                  firebaseAuth: FirebaseAuth.instance,
                ),
              )..add(AppStarted()),
            )
          ],
          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              print('Service (AuthenticationBloc): $state');
              return child;
            },
          ),
        );
      },
    );
  }
}
