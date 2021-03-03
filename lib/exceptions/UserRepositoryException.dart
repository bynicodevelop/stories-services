import 'package:flutter/cupertino.dart';

class UserRepositoryException implements Exception {
  static const String BAD_CREDENTIALS = 'BAD_CREDENTIALS';
  static const String TOO_MANY_REQUESTS = 'TOO_MANY_REQUESTS';
  static const String REQUIRES_RECENT_LOGIN = 'REQUIRES_RECENT_LOGIN';
  static const String EMAIL_ALREADY_EXISTS = 'EMAIL_ALREADY_EXISTS';
  static const String INVALID_EMAIL = 'INVALID_EMAIL';

  final String code;
  final String message;

  const UserRepositoryException({
    @required this.code,
    this.message,
  });
}
