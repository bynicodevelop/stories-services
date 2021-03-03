import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AuthenticationInitialState extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final String userId;
  final String email;

  const Authenticated({
    this.userId,
    this.email,
  });

  @override
  List<Object> get props => [userId, email];

  @override
  String toString() => 'Authenticated { userId: $userId, email: $email }';
}

class Unauthenticated extends AuthenticationState {}

class ProfileUpdated extends AuthenticationState {}

class AuthenticationErrors extends AuthenticationState {
  final String errorCode;

  AuthenticationErrors({this.errorCode});

  List<Object> get props => [errorCode];
}
