import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cashier_app/l10n/app_localizations.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNavBar({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/sales')) return 1;
    if (location.startsWith('/payments')) return 2;
    if (location.startsWith('/reports')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0; // products (home)
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/sales');
              break;
            case 2:
              context.go('/payments');
              break;
            case 3:
              context.go('/reports');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.store), label: l10n.tabProducts),
          NavigationDestination(icon: const Icon(Icons.receipt_long), label: l10n.tabSales),
          NavigationDestination(icon: const Icon(Icons.payments), label: l10n.tabPayments),
          NavigationDestination(icon: const Icon(Icons.bar_chart), label: l10n.tabReports),
          NavigationDestination(icon: const Icon(Icons.settings), label: l10n.tabSettings),
        ],
      ),
    );
  }
}
