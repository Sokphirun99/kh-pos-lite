import 'package:flutter_test/flutter_test.dart';

import 'package:cashier_app/features/auth/bloc/auth_bloc.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await ensureTestHydratedStorage();
  });

  group('AuthBloc', () {
    test('initial state unauthenticated', () {
      final bloc = AuthBloc(tokenStorage: MemoryTokenStorage(), authService: TestAuthService());
      expect(bloc.state.when(
        unauthenticated: () => true,
        authenticating: () => false,
        error: (_) => false,
        authenticated: (_) => false,
      ), true);
      bloc.close();
    });

    test('emits authenticating -> authenticated on success', () async {
      final bloc = AuthBloc(tokenStorage: MemoryTokenStorage(), authService: TestAuthService());
      addTearDown(bloc.close);
      final expected = expectLater(
        bloc.stream,
        emitsInOrder([
          const AuthState.authenticating(),
          isA<AuthState>().having(
            (s) => s.maybeWhen(authenticated: (t) => t, orElse: () => null),
            'token',
            isNotEmpty,
          ),
        ]),
      );
      bloc.add(const AuthLoginRequested(email: 'a@b.com', password: 'x'));
      await expected;
    });

    test('emits authenticating -> error on 401', () async {
      final svc = TestAuthService()..fail401 = true;
      final bloc = AuthBloc(tokenStorage: MemoryTokenStorage(), authService: svc);
      addTearDown(bloc.close);
      final expected = expectLater(
        bloc.stream,
        emitsInOrder([
          const AuthState.authenticating(),
          const AuthState.error(message: 'Invalid email or password'),
        ]),
      );
      bloc.add(const AuthLoginRequested(email: 'a@b.com', password: 'bad'));
      await expected;
    });

    test('emits authenticating -> error on network error', () async {
      final svc = TestAuthService()..failNetwork = true;
      final bloc = AuthBloc(tokenStorage: MemoryTokenStorage(), authService: svc);
      addTearDown(bloc.close);
      final expected = expectLater(
        bloc.stream,
        emitsInOrder([
          const AuthState.authenticating(),
          const AuthState.error(message: 'Network error, please try again'),
        ]),
      );
      bloc.add(const AuthLoginRequested(email: 'a@b.com', password: 'x'));
      await expected;
    });
  });
}
