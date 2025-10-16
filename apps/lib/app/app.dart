import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../routers/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/settings/bloc/theme_cubit.dart';
import '../features/settings/bloc/locale_cubit.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/sales/bloc/sales_bloc.dart';
import '../features/payments/bloc/payments_bloc.dart';
import '../features/reports/bloc/reports_cubit.dart';
import '../features/sync/bloc/sync_bloc.dart';
import '../services/sync_service.dart';
import '../features/sync/view/connectivity_sync_listener.dart';
import '../data/remote/api_client.dart';
import '../domain/repositories/sale_repository.dart';
import '../domain/repositories/payment_repository.dart';
import '../features/settings/bloc/feature_flags_cubit.dart';
import '../core/env/config.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (ctx) => SalesBloc(ctx.read<SaleRepository>())),
        BlocProvider(
          create: (ctx) => PaymentsBloc(ctx.read<PaymentRepository>()),
        ),
        BlocProvider(create: (_) => ReportsCubit()),
        BlocProvider(create: (_) => FeatureFlagsCubit()),
        BlocProvider(
          create: (ctx) {
            // Check if we're in offline mode
            const isOffline = bool.fromEnvironment('OFFLINE_MODE', defaultValue: false);
            
            if (isOffline || EnvConfig.current.isOfflineOnly) {
              // Use a no-op sync service for offline mode
              final api = buildApiClient(
                token: null,
                baseUrl: '', // No API needed
              );
              return SyncBloc(SyncService(api));
            } else {
              // Normal online mode
              final token = ctx.read<AuthBloc>().state.whenOrNull(
                authenticated: (t) => t,
              );
              final api = buildApiClient(
                token: token,
                baseUrl: EnvConfig.current.apiBaseUrl,
              );
              return SyncBloc(SyncService(api));
            }
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = buildRouter(context);
          final isDark = context.watch<ThemeCubit>().state;
          final locale = context.watch<LocaleCubit>().state;
          return Builder(
            builder: (context) {
              // Check if we're in offline mode
              const isOffline = bool.fromEnvironment('OFFLINE_MODE', defaultValue: false);
              
              final child = DynamicColorBuilder(
                builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
                  final lightScheme =
                      lightDynamic ??
                      ColorScheme.fromSeed(seedColor: AppTheme.seed);
                  final darkScheme =
                      darkDynamic ??
                      ColorScheme.fromSeed(
                        seedColor: AppTheme.seed,
                        brightness: Brightness.dark,
                      );

                  return MaterialApp.router(
                    title: isOffline ? 'KH POS Lite (Offline)' : 'KH POS Lite',
                    theme: AppTheme.lightFrom(lightScheme),
                    darkTheme: AppTheme.darkFrom(darkScheme),
                    themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    locale: locale,
                    routerConfig: router,
                  );
                },
              );

              // Only wrap with ConnectivitySyncListener if not in offline mode
              if (isOffline || EnvConfig.current.isOfflineOnly) {
                return child;
              } else {
                return ConnectivitySyncListener(child: child);
              }
            },
          );
        },
      ),
    );
  }
}
