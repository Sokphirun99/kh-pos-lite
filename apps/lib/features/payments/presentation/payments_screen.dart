import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:cashier_app/domain/entities/payment.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';
import 'package:cashier_app/domain/repositories/payment_repository.dart';
import 'package:cashier_app/features/common/widgets/empty_placeholder.dart';
import 'package:cashier_app/features/common/widgets/sync_banner.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:cashier_app/services/key_value_service.dart';

import '../bloc/payments_bloc.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

enum _PaymentFilter { all, cash, transfer }

class _PaymentsScreenState extends State<PaymentsScreen> {
  _PaymentFilter _filter = _PaymentFilter.all;
  String _query = '';

  void _onFilterChanged(_PaymentFilter filter) {
    setState(() => _filter = filter);
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value.trim().toLowerCase());
  }

  Future<void> _openAddPaymentSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final draft = await showModalBottomSheet<_PaymentDraft>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PaymentEntrySheet(l10n: l10n),
    );
    if (draft == null) return;
    final payment = Payment(
      id: const Uuid().v4(),
      saleId: draft.saleId,
      method: draft.method,
      amount: MoneyRiel(draft.amount),
    );
    await context.read<PaymentRepository>().add(payment);
    if (draft.reference != null && draft.reference!.isNotEmpty) {
      await KeyValueService.set('payment_ref_${payment.id}', draft.reference!);
    }
  }

  void _deletePayment(BuildContext context, Payment payment, String? reference) {
    final bloc = context.read<PaymentsBloc>();
    bloc.add(PaymentDeleted(payment.id));
    if (reference != null && reference.isNotEmpty) {
      KeyValueService.remove('payment_ref_${payment.id}');
    }
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.settingsSyncDeleted),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () {
            bloc.add(PaymentAdded(payment));
            if (reference != null && reference.isNotEmpty) {
              KeyValueService.set('payment_ref_${payment.id}', reference);
            }
          },
        ),
      ),
    );
  }

  void _copyReference(BuildContext context, String reference) {
    Clipboard.setData(ClipboardData(text: reference));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).aboutCopied)),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AppBar(
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.paymentsTitle),
          const SizedBox(height: 4),
          Text(
            l10n.paymentsSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => PaymentsBloc(ctx.read<PaymentRepository>())..add(const PaymentsSubscribed()),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            const SyncBanner(),
            Expanded(
              child: BlocBuilder<PaymentsBloc, PaymentsState>(
                builder: (context, state) {
                  final l10n = AppLocalizations.of(context);
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final references = <String, String>{};
                  for (final payment in state.items) {
                    final ref = KeyValueService.get<String>('payment_ref_${payment.id}');
                    if (ref != null && ref.isNotEmpty) {
                      references[payment.id] = ref;
                    }
                  }

                  final filtered = state.items.where((payment) {
                    if (_filter != _PaymentFilter.all) {
                      final target = _filter == _PaymentFilter.cash ? 'cash' : 'transfer';
                      if (payment.method.toLowerCase() != target) return false;
                    }
                    if (_query.isEmpty) return true;
                    final ref = references[payment.id]?.toLowerCase() ?? '';
                    final saleId = payment.saleId.toLowerCase();
                    final method = payment.method.toLowerCase();
                    final id = payment.id.toLowerCase();
                    return saleId.contains(_query) || ref.contains(_query) || method.contains(_query) || id.contains(_query);
                  }).toList();

                  final format = NumberFormat.decimalPattern(l10n.localeName);
                  final total = filtered.fold<int>(0, (sum, p) => sum + p.amount.amount);
                  final cashAmount = filtered
                      .where((p) => p.method.toLowerCase() == 'cash')
                      .fold<int>(0, (sum, p) => sum + p.amount.amount);
                  final transferAmount = filtered
                      .where((p) => p.method.toLowerCase() == 'transfer')
                      .fold<int>(0, (sum, p) => sum + p.amount.amount);

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PaymentsSummaryCard(
                              l10n: l10n,
                              format: format,
                              totalAmount: total,
                              cashAmount: cashAmount,
                              transferAmount: transferAmount,
                              totalCount: filtered.length,
                            ),
                            const SizedBox(height: 16),
                            _PaymentsFilterBar(
                              l10n: l10n,
                              filter: _filter,
                              onFilterChanged: _onFilterChanged,
                              onSearchChanged: _onSearchChanged,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: filtered.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: EmptyPlaceholder(
                                  icon: Icons.payments_outlined,
                                  title: l10n.noPayments,
                                  message: l10n.paymentsEmptyDescription,
                                  actionLabel: l10n.receivePayment,
                                  onActionPressed: () => _openAddPaymentSheet(context),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 104),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (_, index) {
                                  final payment = filtered[index];
                                  final reference = references[payment.id];
                                  return Dismissible(
                                    key: ValueKey(payment.id),
                                    direction: DismissDirection.endToStart,
                                    background: const _DismissibleBackground(),
                                    confirmDismiss: (_) async {
                                      _deletePayment(context, payment, reference);
                                      return true;
                                    },
                                    child: _PaymentCard(
                                      payment: payment,
                                      reference: reference,
                                      currencyFormat: format,
                                      onCopyReference: reference == null
                                          ? null
                                          : () => _copyReference(context, reference),
                                      onDelete: () => _deletePayment(context, payment, reference),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openAddPaymentSheet(context),
          icon: const Icon(Icons.add),
          label: Text(AppLocalizations.of(context).receivePayment),
        ),
      ),
    );
  }
}

class _PaymentsSummaryCard extends StatelessWidget {
  const _PaymentsSummaryCard({
    required this.l10n,
    required this.format,
    required this.totalAmount,
    required this.cashAmount,
    required this.transferAmount,
    required this.totalCount,
  });

  final AppLocalizations l10n;
  final NumberFormat format;
  final int totalAmount;
  final int cashAmount;
  final int transferAmount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [scheme.primaryContainer, scheme.secondaryContainer]),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.paymentsSummaryCollected,
            style: theme.textTheme.labelLarge?.copyWith(color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 6),
          Text(
            '៛${format.format(totalAmount)}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _SummaryTile(
                label: l10n.paymentsSummaryCount,
                value: '$totalCount',
              ),
              const SizedBox(width: 12),
              _SummaryTile(
                label: l10n.checkoutCash,
                value: '៛${format.format(cashAmount)}',
              ),
              const SizedBox(width: 12),
              _SummaryTile(
                label: l10n.checkoutTransfer,
                value: '៛${format.format(transferAmount)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentsFilterBar extends StatelessWidget {
  const _PaymentsFilterBar({
    required this.l10n,
    required this.filter,
    required this.onFilterChanged,
    required this.onSearchChanged,
  });

  final AppLocalizations l10n;
  final _PaymentFilter filter;
  final ValueChanged<_PaymentFilter> onFilterChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<_PaymentFilter>(
          segments: [
            ButtonSegment(value: _PaymentFilter.all, label: Text(l10n.paymentsFilterAll), icon: const Icon(Icons.all_inbox)),
            ButtonSegment(value: _PaymentFilter.cash, label: Text(l10n.paymentsFilterCash), icon: const Icon(Icons.payments)),
            ButtonSegment(
              value: _PaymentFilter.transfer,
              label: Text(l10n.paymentsFilterTransfer),
              icon: const Icon(Icons.account_balance_wallet_outlined),
            ),
          ],
          selected: {filter},
          onSelectionChanged: (values) => onFilterChanged(values.first),
        ),
        const SizedBox(height: 12),
        SearchBar(
          leading: const Icon(Icons.search),
          hintText: l10n.paymentsSearchHint,
          onChanged: onSearchChanged,
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.payment,
    required this.reference,
    required this.currencyFormat,
    required this.onDelete,
    this.onCopyReference,
  });

  final Payment payment;
  final String? reference;
  final NumberFormat currencyFormat;
  final VoidCallback onDelete;
  final VoidCallback? onCopyReference;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final method = payment.method.toLowerCase() == 'transfer' ? l10n.checkoutTransfer : l10n.checkoutCash;
    final methodIcon = payment.method.toLowerCase() == 'transfer' ? Icons.account_balance : Icons.payments_outlined;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Icon(methodIcon, color: theme.colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '៛${currencyFormat.format(payment.amount.amount)}',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${payment.id.substring(0, 6).toUpperCase()}',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.settingsSyncDeleted,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _InfoChip(icon: methodIcon, label: method),
                _InfoChip(icon: Icons.sell_outlined, label: '${l10n.paymentsFormSaleId}: ${payment.saleId}'),
                if (reference != null && reference!.isNotEmpty)
                  GestureDetector(
                    onTap: onCopyReference,
                    child: _InfoChip(
                      icon: Icons.copy_all_outlined,
                      label: l10n.txRefLabel(reference!),
                    ),
                  ),
              ],
            ),
            if (reference != null && reference!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onCopyReference,
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.aboutCopied),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 18, color: theme.colorScheme.primary),
      label: Text(label),
    );
  }
}

class _DismissibleBackground extends StatelessWidget {
  const _DismissibleBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            AppLocalizations.of(context).settingsSyncDeleted,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onError,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.delete_outline, color: theme.colorScheme.onError),
        ],
      ),
    );
  }
}

class _PaymentDraft {
  const _PaymentDraft({
    required this.saleId,
    required this.method,
    required this.amount,
    this.reference,
  });

  final String saleId;
  final String method;
  final int amount;
  final String? reference;
}

enum _EntryMethod { cash, transfer }

class _PaymentEntrySheet extends StatefulWidget {
  const _PaymentEntrySheet({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_PaymentEntrySheet> createState() => _PaymentEntrySheetState();
}

class _PaymentEntrySheetState extends State<_PaymentEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  final _saleIdCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  _EntryMethod _method = _EntryMethod.cash;

  @override
  void dispose() {
    _saleIdCtrl.dispose();
    _amountCtrl.dispose();
    _referenceCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = int.tryParse(_amountCtrl.text.trim()) ?? 0;
    Navigator.of(context).pop(
      _PaymentDraft(
        saleId: _saleIdCtrl.text.trim(),
        method: _method == _EntryMethod.cash ? 'cash' : 'transfer',
        amount: amount,
        reference: _referenceCtrl.text.trim().isEmpty ? null : _referenceCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final l10n = widget.l10n;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.receivePayment,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.paymentsMethodLabel,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              SegmentedButton<_EntryMethod>(
                segments: [
                  ButtonSegment(
                    value: _EntryMethod.cash,
                    label: Text(l10n.checkoutCash),
                    icon: const Icon(Icons.payments_outlined),
                  ),
                  ButtonSegment(
                    value: _EntryMethod.transfer,
                    label: Text(l10n.checkoutTransfer),
                    icon: const Icon(Icons.account_balance),
                  ),
                ],
                selected: {_method},
                onSelectionChanged: (value) => setState(() => _method = value.first),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _saleIdCtrl,
                decoration: InputDecoration(
                  labelText: l10n.paymentsFormSaleId,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.trim().isEmpty ? l10n.formRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                decoration: InputDecoration(
                  labelText: l10n.checkoutAmountReceived,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return l10n.formRequired;
                  final parsed = int.tryParse(text);
                  if (parsed == null || parsed <= 0) return l10n.formNonNegative;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referenceCtrl,
                decoration: InputDecoration(
                  labelText: l10n.checkoutTxReference,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.paymentsFormSubmit),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
