import 'package:flutter/cupertino.dart';

class ReservationRepositoryException implements Exception {
  static const String SLUG_ALREADY_EXISTS = 'SLUG_ALREADY_EXISTS';

  final String code;
  final String message;

  const ReservationRepositoryException({
    @required this.code,
    this.message,
  });
}
