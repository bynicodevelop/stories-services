import 'package:flutter/cupertino.dart';

class UserRepositoryException implements Exception {
  static const String BAD_CREDENTIALS = 'BAD_CREDENTIALS';
  static const String TOO_MANY_REQUESTS = 'TOO_MANY_REQUESTS';

  final String code;
  final String message;

  const UserRepositoryException({
    @required this.code,
    this.message,
  });
}
