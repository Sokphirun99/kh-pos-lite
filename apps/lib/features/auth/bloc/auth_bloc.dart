import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:cashier_app/services/token_storage.dart';
import 'package:cashier_app/features/auth/application/auth_service.dart';
import 'package:cashier_app/data/remote/api_client.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final TokenStorage _tokenStorage;
  final AuthService _authService;

  AuthBloc({TokenStorage? tokenStorage, AuthService? authService})
      : _tokenStorage = tokenStorage ?? const TokenStorage(),
        _authService = authService ?? AuthService(buildApiClient()),
        super(const AuthState.unauthenticated()) {
    on<AuthSignedIn>(_onSignedIn);
    on<AuthSignedOut>(_onSignedOut);
    on<AuthLoginRequested>(_onLoginRequested);
    on<_AuthLoaded>(_onLoaded);
    add(const _AuthLoaded());
  }

  FutureOr<void> _onSignedIn(AuthSignedIn event, Emitter<AuthState> emit) async {
    emit(const AuthState.authenticating());
    try {
      // Simulate a small delay; replace with real API validation if needed
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await _tokenStorage.write(event.token);
      emit(AuthState.authenticated(token: event.token));
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  FutureOr<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.authenticating());
    try {
      final token = await _authService.signIn(email: event.email, password: event.password);
      await _tokenStorage.write(token);
      emit(AuthState.authenticated(token: token));
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  FutureOr<void> _onSignedOut(AuthSignedOut event, Emitter<AuthState> emit) async {
    await _tokenStorage.clear();
    emit(const AuthState.unauthenticated());
  }

  FutureOr<void> _onLoaded(_AuthLoaded event, Emitter<AuthState> emit) async {
    // If hydrated has no token, try secure storage
    final current = state;
    final hasToken = current.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
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
