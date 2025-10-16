import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cashier_app/features/auth/bloc/auth_bloc.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:cashier_app/services/key_value_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withOpacity(0.08),
              scheme.secondaryContainer.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: _LoginCard(l10n: l10n),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatefulWidget {
  const _LoginCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = false;

  static const _kvRememberEmailKey = 'remember_email';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Prefill remembered email if present
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final saved = KeyValueService.get<String>(_kvRememberEmailKey);
      if (!mounted) return;
      if (saved != null && saved.isNotEmpty) {
        setState(() {
          _emailCtrl.text = saved;
          _rememberMe = true;
        });
      }
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Persist or clear remembered email
    if (_rememberMe) {
      KeyValueService.set<String>(_kvRememberEmailKey, _emailCtrl.text.trim());
    } else {
      KeyValueService.remove(_kvRememberEmailKey);
    }
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = widget.l10n;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        // Persist remember-me email only on successful login
        state.when(
          unauthenticated: () {},
          authenticating: () {},
          error: (_) {},
          authenticated: (_) async {
            if (_rememberMe) {
              await KeyValueService.set<String>(
                _kvRememberEmailKey,
                _emailCtrl.text.trim(),
              );
            } else {
              await KeyValueService.remove(_kvRememberEmailKey);
            }
            if (!context.mounted) return;
            context.go('/');
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          authenticating: () => true,
          orElse: () => false,
        );
        final String? errorText = state.maybeWhen(
          error: (msg) => msg,
          orElse: () => null,
        );

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.storefront_outlined,
                    size: 36,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.loginSubtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: scheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorText,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        enabled: !isLoading,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        decoration: InputDecoration(
                          labelText: l10n.loginEmailLabel,
                          prefixIcon: const Icon(Icons.alternate_email),
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return l10n.fieldRequired;
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordCtrl,
                        enabled: !isLoading,
                        obscureText: _obscure,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: l10n.loginPasswordLabel,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _obscure ? l10n.show : l10n.hide,
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? l10n.fieldRequired
                            : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: isLoading
                                ? null
                                : (v) =>
                                      setState(() => _rememberMe = v ?? false),
                          ),
                          const SizedBox(width: 4),
                          Text('Remember me'),
                          const Spacer(),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    const urlStr =
                                        'https://example.com/forgot'; // TODO: replace with real URL
                                    final uri = Uri.parse(urlStr);
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    try {
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Forgot password page unavailable',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (_) {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Forgot password page unavailable',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            child: const Text('Forgot password?'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: isLoading ? null : _submit,
                    icon: isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.login),
                    label: Text(l10n.loginSignIn),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.settingsGeneralSectionSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Removed unused _LoginFeature widget.
