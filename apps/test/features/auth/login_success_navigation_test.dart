import 'package:cashier_app/features/auth/bloc/auth_bloc.dart';
import 'package:cashier_app/features/auth/presentation/login_screen.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:cashier_app/routers/go_router.dart' show GoRouterRefreshStream;
import 'package:cashier_app/services/key_value_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await ensureTestHydratedStorage();
  });

  late MemoryKeyValueBackend kvBackend;

  setUp(() async {
    kvBackend = MemoryKeyValueBackend();
    KeyValueService.debugSetBackend(kvBackend);
    await KeyValueService.init();
    await KeyValueService.clear();
  });

  testWidgets('navigates away after successful authentication', (tester) async {
    final authService = TestAuthService();
    final bloc = AuthBloc(
      tokenStorage: MemoryTokenStorage(),
      authService: authService,
    );
    addTearDown(bloc.close);

    final refresh = GoRouterRefreshStream(bloc.stream);
    final router = GoRouter(
      initialLocation: '/login',
      refreshListenable: refresh,
      redirect: (_, state) {
        final loggedIn = bloc.state.maybeWhen(
          authenticated: (_) => true,
          orElse: () => false,
        );
        final goingToLogin = state.matchedLocation == '/login';
        if (!loggedIn && !goingToLogin) return '/login';
        if (loggedIn && goingToLogin) return '/';
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const _HomeStub()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      ],
    );
    addTearDown(router.dispose);
    addTearDown(refresh.dispose);

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: bloc,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    expect(find.byType(LoginScreen), findsOneWidget);

    bloc.add(
      const AuthLoginRequested(email: 'user@example.com', password: 'secret'),
    );
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(_HomeStub), findsOneWidget);
  });
}

class _HomeStub extends StatelessWidget {
  const _HomeStub();

  @override
  Widget build(BuildContext context) => const SizedBox(key: Key('home-stub'));
}
