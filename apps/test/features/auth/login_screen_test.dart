import 'package:cashier_app/features/auth/bloc/auth_bloc.dart';
import 'package:cashier_app/features/auth/presentation/login_screen.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:cashier_app/services/key_value_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

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

  testWidgets('shows error banner when login fails', (tester) async {
    final authService = TestAuthService()..fail401 = true;
    final bloc = AuthBloc(tokenStorage: MemoryTokenStorage(), authService: authService);
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<AuthBloc>.value(
          value: bloc,
          child: const LoginScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.byType(FilledButton));

    await tester.pumpAndSettle();

    expect(find.text('Invalid email or password'), findsOneWidget);
  });

  testWidgets('persists remembered email on submit', (tester) async {
    final authService = TestAuthService()..fail401 = true;
    final bloc = AuthBloc(tokenStorage: MemoryTokenStorage(), authService: authService);
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<AuthBloc>.value(
          value: bloc,
          child: const LoginScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'remember@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(kvBackend.get<String>('remember_email'), 'remember@example.com');
  });
}
