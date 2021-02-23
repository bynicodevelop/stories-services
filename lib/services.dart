library services;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services/blocs/authentication/authentication_bloc.dart';
import 'package:services/blocs/bloc.dart';
import 'package:services/blocs/reservation/bloc.dart';
import 'package:services/repositories/FirebaseReservationRepository.dart';
import 'package:services/repositories/FirebaseUserRepository.dart';
import 'package:flutter/foundation.dart';

class Services extends StatelessWidget {
  final bool isDevelopement;
  final Widget child;

  Services({
    Key key,
    this.child,
    this.isDevelopement = false,
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

        FirebaseFirestore firestore = FirebaseFirestore.instance;

        if (isDevelopement) {
          String host = defaultTargetPlatform == TargetPlatform.android
              ? '10.0.2.2:8080'
              : 'localhost:8080';

          firestore.settings = Settings(host: host, sslEnabled: false);
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthenticationBloc>(
              create: (context) => AuthenticationBloc(
                userRepository: FirebaseUserRepository(
                  firebaseAuth: FirebaseAuth.instance,
                ),
              )..add(AppStarted()),
            ),
            BlocProvider<ReservationBloc>(
              create: (context) => ReservationBloc(
                reservationRepository: FirebaseReservationRepository(
                  firestore: firestore,
                ),
              ),
            ),
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
