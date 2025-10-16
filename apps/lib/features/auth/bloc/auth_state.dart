part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.authenticating() = _Authenticating;
  const factory AuthState.error({required String message}) = _AuthError;
  const factory AuthState.authenticated({required String token}) =
      _Authenticated;

  T when<T>({
    required T Function() unauthenticated,
    required T Function() authenticating,
    required T Function(String message) error,
    required T Function(String token) authenticated,
  }) {
    if (this is _Unauthenticated) return unauthenticated();
    if (this is _Authenticating) return authenticating();
    if (this is _AuthError) return error((this as _AuthError).message);
    return authenticated((this as _Authenticated).token);
  }

  T? whenOrNull<T>({
    T Function()? unauthenticated,
    T Function()? authenticating,
    T Function(String message)? error,
    T Function(String token)? authenticated,
  }) {
    if (this is _Unauthenticated) return unauthenticated?.call();
    if (this is _Authenticating) return authenticating?.call();
    if (this is _AuthError) return error?.call((this as _AuthError).message);
    return authenticated?.call((this as _Authenticated).token);
  }

  T maybeWhen<T>({
    T Function()? orElse,
    T Function()? unauthenticated,
    T Function()? authenticating,
    T Function(String message)? error,
    T Function(String token)? authenticated,
  }) {
    if (this is _Unauthenticated && unauthenticated != null)
      return unauthenticated();
    if (this is _Authenticating && authenticating != null)
      return authenticating();
    if (this is _AuthError && error != null)
      return error((this as _AuthError).message);
    if (this is _Authenticated && authenticated != null)
      return authenticated((this as _Authenticated).token);
    return orElse != null ? orElse() : null as T;
  }

  @override
  List<Object?> get props => []; // subclasses override
}

class _Unauthenticated extends AuthState {
  const _Unauthenticated();
}

class _Authenticating extends AuthState {
  const _Authenticating();
}

class _AuthError extends AuthState {
  final String message;
  const _AuthError({required this.message});
  @override
  List<Object?> get props => [message];
}

class _Authenticated extends AuthState {
  final String token;
  const _Authenticated({required this.token});
  @override
  List<Object?> get props => [token];
}
