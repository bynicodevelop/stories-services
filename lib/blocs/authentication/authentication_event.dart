import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {}

class AppStarted extends AuthenticationEvent {
  @override
  List<Object> get props => [];
}

class SignInWithEmailAndPassword extends AuthenticationEvent {
  final String email;
  final String password;

  SignInWithEmailAndPassword({this.email, this.password});

  @override
  List<Object> get props => [email, password];
}

class SignOut extends AuthenticationEvent {
  @override
  List<Object> get props => [];
}

class UserAuthenticated extends AuthenticationEvent {
  final String uid;

  UserAuthenticated({this.uid});

  @override
  List<Object> get props => [uid];
}

class UpdateEmailProfileEvent extends AuthenticationEvent {
  final String email;

  UpdateEmailProfileEvent(this.email);

  @override
  // TODO: implement props
  List<Object> get props => [email];
}
