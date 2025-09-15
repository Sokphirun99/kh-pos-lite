part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthSignedIn extends AuthEvent {
  final String token;
  const AuthSignedIn(this.token);
  @override
  List<Object?> get props => [token];
}

class AuthSignedOut extends AuthEvent {
  const AuthSignedOut();
}

