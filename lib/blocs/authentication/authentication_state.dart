import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final String userId;

  const Authenticated(this.userId);

  @override
  List<Object> get props => [userId];

  @override
  String toString() => 'Authenticated { userId: $userId }';
}

class Unauthenticated extends AuthenticationState {}

class AuthenticationErrors extends AuthenticationState {
  final String errorCode;

  AuthenticationErrors({this.errorCode});

  List<Object> get props => [errorCode];
}
