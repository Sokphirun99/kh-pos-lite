import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../routers/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc_observer.dart';
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
import '../features/auth/bloc/auth_bloc.dart';
import '../domain/repositories/sale_repository.dart';
import '../domain/repositories/payment_repository.dart';
import '../features/settings/bloc/feature_flags_cubit.dart';

/// App root: place for providers/routing later.
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
        BlocProvider(create: (ctx) => PaymentsBloc(ctx.read<PaymentRepository>())),
        BlocProvider(create: (_) => ReportsCubit()),
        BlocProvider(create: (_) => FeatureFlagsCubit()),
        BlocProvider(create: (ctx) {
          final token = ctx.read<AuthBloc>().state.when(
                unauthenticated: () => null,
                authenticated: (t) => t,
              );
          final api = buildApiClient(token: token);
          return SyncBloc(SyncService(api));
        }),
      ],
      child: Builder(builder: (context) {
        final router = buildRouter(context);
        final isDark = context.watch<ThemeCubit>().state;
        final locale = context.watch<LocaleCubit>().state;
        return ConnectivitySyncListener(
          child: MaterialApp.router(
            title: 'KH POS Lite',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            routerConfig: router,
          ),
        );
      }),
    );
  }
}

/// Temporary home placeholder until real routing is added.
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
