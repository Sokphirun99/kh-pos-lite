import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashier_app/features/auth/bloc/auth_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            context.read<AuthBloc>().add(const AuthSignedIn('dev-token'));
            // Optionally preload other state here
            if (context.mounted) context.go('/');
          },
          child: Text(l10n.loginSignIn),
        ),
      ),
    );
  }
}
