import 'package:flutter/material.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:cashier_app/features/common/widgets/empty_placeholder.dart';
import 'customer_form_page.dart';
import 'package:go_router/go_router.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final List<CustomerDraft> _customers = [];
  String _query = '';

  List<CustomerDraft> get _filteredCustomers {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(_customers);
    return _customers
        .where((c) {
          final name = c.name.toLowerCase();
          final phone = c.phone.toLowerCase();
          final alt = c.altPhone.toLowerCase();
          return name.contains(q) || phone.contains(q) || alt.contains(q);
        })
        .toList();
  }

  // Using Material 3 SearchBar; no custom decoration needed.

  Future<void> _createCustomer() async {
    final result = await context.pushNamed<CustomerDraft>('customer_new');
    if (result == null) return;
    setState(() => _customers.add(result));
  }

  Future<void> _editCustomer(CustomerDraft customer) async {
    final result = await context.pushNamed<CustomerDraft>('customer_edit', pathParameters: {'id': customer.id}, extra: customer);
    if (result == null) return;
    setState(() {
      final index = _customers.indexWhere((element) => element.id == result.id);
      if (index >= 0) {
        _customers[index] = result;
      }
    });
  }

  void _removeCustomer(CustomerDraft customer) {
    setState(() => _customers.removeWhere((c) => c.id == customer.id));
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.customersDeleted),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () {
            setState(() => _customers.insert(0, customer));
          },
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyPlaceholder(
      icon: Icons.person_outline,
      title: l10n.customersEmptyTitle,
      message: l10n.customersEmptySubtitle,
      actionLabel: l10n.customersCreateButton,
      onActionPressed: _createCustomer,
    );
  }

  Widget _buildCustomerCard(BuildContext context, CustomerDraft customer) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final muted = theme.colorScheme.onSurfaceVariant.withOpacity(0.8);
    final chips = <Widget>[];
    if (customer.phone.isNotEmpty) {
      chips.add(_infoChip(context, customer.phone, Icons.call));
    }
    if (customer.altPhone.isNotEmpty) {
      chips.add(_infoChip(context, customer.altPhone, Icons.phone_iphone));
    }
    if (customer.vatTin.isNotEmpty) {
      chips.add(_infoChip(context, '${l10n.customersVatLabel}: ${customer.vatTin}', Icons.badge_outlined));
    }

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _editCustomer(customer),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer.name, style: theme.textTheme.titleMedium),
                        if (chips.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: chips,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _removeCustomer(customer),
                  ),
                ],
              ),
              if (customer.address.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(customer.address, style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
              ],
              if (customer.note.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(customer.note, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(BuildContext context, String text, IconData icon) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 18, color: theme.colorScheme.primary),
      label: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtered = _filteredCustomers;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabCustomers),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SearchBar(
              hintText: l10n.customersSearchHint,
              leading: const Icon(Icons.search),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? _emptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, index) {
                      final customer = filtered[index];
                      return Dismissible(
                        key: ValueKey(customer.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onDismissed: (_) => _removeCustomer(customer),
                        child: _buildCustomerCard(context, customer),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCustomer,
        icon: const Icon(Icons.add),
        label: Text(l10n.customersCreateButton),
      ),
    );
  }
}
