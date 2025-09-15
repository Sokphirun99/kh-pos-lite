part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.authenticated({required String token}) = _Authenticated;

  T when<T>({required T Function() unauthenticated, required T Function(String token) authenticated}) {
    if (this is _Unauthenticated) return unauthenticated();
    final a = this as _Authenticated;
    return authenticated(a.token);
  }

  T? whenOrNull<T>({T Function()? unauthenticated, T Function(String token)? authenticated}) {
    if (this is _Unauthenticated) return unauthenticated?.call();
    final a = this as _Authenticated;
    return authenticated?.call(a.token);
  }

  T maybeWhen<T>({T Function()? orElse, T Function(String token)? authenticated}) {
    if (this is _Authenticated && authenticated != null) return authenticated((this as _Authenticated).token);
    return orElse != null ? orElse() : null as T;
  }

  @override
  List<Object?> get props => []; // subclasses override
}

class _Unauthenticated extends AuthState {
  const _Unauthenticated();
}

class _Authenticated extends AuthState {
  final String token;
  const _Authenticated({required this.token});
  @override
  List<Object?> get props => [token];
}

