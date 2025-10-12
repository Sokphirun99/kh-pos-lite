import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cashier_app/l10n/app_localizations.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNavBar({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/customers')) return 1;
    if (location.startsWith('/sales')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0; // items (home)
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              context.go('/customers');
              break;
            case 2:
              context.go('/sales');
              break;
            case 3:
              context.go('/settings');
              break;
          }
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.inventory_2_outlined), label: l10n.tabItems),
          NavigationDestination(icon: const Icon(Icons.people_alt_outlined), label: l10n.tabCustomers),
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), label: l10n.tabInvoices),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), label: l10n.tabSettings),
        ],
      ),
    );
  }
}
