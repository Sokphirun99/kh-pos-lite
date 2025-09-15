import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cashier_app/features/products/presentation/products_screen.dart';
import 'package:cashier_app/features/products/presentation/stock_adjustments_screen.dart';
import 'package:cashier_app/features/sales/presentation/sales_screen.dart';
import 'package:cashier_app/features/sales/presentation/sale_detail_screen.dart';
import 'package:cashier_app/features/receipts/receipt_preview_screen.dart';
import 'package:cashier_app/features/printing/printer_screen.dart';
import 'package:cashier_app/features/payments/presentation/payments_screen.dart';
import 'package:cashier_app/features/reports/presentation/reports_screen.dart';
import 'package:cashier_app/features/settings/presentation/settings_screen.dart';
import 'package:cashier_app/features/sales/presentation/sell_screen.dart';
import 'package:cashier_app/features/auth/bloc/auth_bloc.dart';
import 'package:cashier_app/features/auth/presentation/login_screen.dart';
import 'scaffold_with_nav.dart';
import 'package:cashier_app/features/settings/presentation/about_page.dart';

GoRouter buildRouter(BuildContext context) {
  final key = GlobalKey<NavigatorState>();

  bool isLoggedIn() => context.read<AuthBloc>().state.when(
        unauthenticated: () => false,
        authenticated: (_) => true,
      );

  return GoRouter(
    navigatorKey: key,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(context.read<AuthBloc>().stream),
    redirect: (context, state) {
      final goingToLogin = state.matchedLocation == '/login';
      final loggedIn = isLoggedIn();
      if (!loggedIn && !goingToLogin) return '/login';
      if (loggedIn && goingToLogin) return '/';
      return null;
    },
    routes: <RouteBase>[
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'products',
            builder: (context, state) => const ProductsScreen(),
          ),
          GoRoute(
            path: '/stock',
            name: 'stock_adjustments',
            builder: (context, state) => const StockAdjustmentsScreen(),
          ),
          GoRoute(
            path: '/sales',
            name: 'sales',
            builder: (context, state) => const SalesScreen(),
          ),
          GoRoute(
            path: '/sales/:id',
            name: 'sale_detail',
            builder: (context, state) => SaleDetailScreen(saleId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/sales/:id/receipt',
            name: 'receipt_preview',
            builder: (context, state) => ReceiptPreviewScreen(saleId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/printers',
            name: 'printers',
            builder: (context, state) => const PrinterScreen(),
          ),
          GoRoute(
            path: '/payments',
            name: 'payments',
            builder: (context, state) => const PaymentsScreen(),
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/sell',
            name: 'sell',
            builder: (context, state) => const SellScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/about',
            name: 'about',
            builder: (context, state) => const AboutPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListener = () => notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListener());
  }

  late final VoidCallback notifyListener;
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
