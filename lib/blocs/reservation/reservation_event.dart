import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ReservationEvent extends Equatable {
  const ReservationEvent();

  @override
  List<Object> get props => [];
}

class InitializeReservation extends ReservationEvent {}

class CreateReservation extends ReservationEvent {
  final String displayName;
  final String slug;
  final String phoneNumber;

  const CreateReservation({
    @required this.displayName,
    @required this.slug,
    @required this.phoneNumber,
  });

  @override
  List<Object> get props => [displayName, slug, phoneNumber];
}

class Reserved extends ReservationEvent {}

class SlugAlreadyExistsReservation extends ReservationEvent {}
