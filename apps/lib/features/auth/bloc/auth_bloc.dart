import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:cashier_app/services/token_storage.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final TokenStorage _tokenStorage;

  AuthBloc({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? const TokenStorage(),
        super(const AuthState.unauthenticated()) {
    on<AuthSignedIn>(_onSignedIn);
    on<AuthSignedOut>(_onSignedOut);
    on<_AuthLoaded>(_onLoaded);
    add(const _AuthLoaded());
  }

  FutureOr<void> _onSignedIn(AuthSignedIn event, Emitter<AuthState> emit) async {
    await _tokenStorage.write(event.token);
    emit(AuthState.authenticated(token: event.token));
  }

  FutureOr<void> _onSignedOut(AuthSignedOut event, Emitter<AuthState> emit) async {
    await _tokenStorage.clear();
    emit(const AuthState.unauthenticated());
  }

  FutureOr<void> _onLoaded(_AuthLoaded event, Emitter<AuthState> emit) async {
    // If hydrated has no token, try secure storage
    final current = state;
    final hasToken = current.when(
      unauthenticated: () => false,
      authenticated: (_) => true,
    );
    if (!hasToken) {
      final token = await _tokenStorage.read();
      if (token != null && token.isNotEmpty) {
        emit(AuthState.authenticated(token: token));
      }
    }
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String?;
    return token == null ? const AuthState.unauthenticated() : AuthState.authenticated(token: token);
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) => state.maybeWhen(
        authenticated: (token) => {'token': token},
        orElse: () => {'token': null},
      );
}

class _AuthLoaded extends AuthEvent {
  const _AuthLoaded();
}
