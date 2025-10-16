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

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthOfflineModeRequested extends AuthEvent {
  const AuthOfflineModeRequested();
}
