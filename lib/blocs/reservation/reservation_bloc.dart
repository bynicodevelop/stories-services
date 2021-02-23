import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:services/blocs/reservation/bloc.dart';
import 'package:services/repositories/ReservationRepository.dart';

class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final ReservationRepository _reservationRepository;

  ReservationBloc({@required ReservationRepository reservationRepository})
      : assert(reservationRepository != null),
        _reservationRepository = reservationRepository,
        super(ReservationState());

  @override
  Stream<ReservationState> mapEventToState(
    ReservationEvent event,
  ) async* {
    print('ReservationBloc - mapEventToState: $event');

    if (event is CreateReservation) {
      if (await _reservationRepository.slugExists(event.slug)) {
        yield state.copyWith(
          status: ReservationStatus.slugAlreadyExists,
        );

        add(InitializeReservation());

        return;
      }

      if (await _reservationRepository.phoneNumberExist(event.phoneNumber)) {
        yield state.copyWith(
          status: ReservationStatus.phoneAlreadyExists,
        );

        add(InitializeReservation());

        return;
      }

      try {
        print('ReservationStatus: ${ReservationStatus.started}');
        yield state.copyWith(
          status: ReservationStatus.started,
        );

        await _reservationRepository.createReservation(
          event.displayName,
          event.slug,
          event.phoneNumber,
        );

        print('ReservationStatus: ${ReservationStatus.complete}');

        yield state.copyWith(
          status: ReservationStatus.complete,
        );

        add(InitializeReservation());
      } catch (e) {
        print('ReservationBloc error: $e');
      }
    } else if (event is InitializeReservation) {
      yield state.copyWith(
        status: ReservationStatus.initial,
      );
    }
  }
}
