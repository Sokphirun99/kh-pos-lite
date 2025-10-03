import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sales_bloc.dart';
import 'package:cashier_app/domain/repositories/sale_repository.dart';
import 'package:cashier_app/domain/entities/sale.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';
import 'package:cashier_app/domain/entities/payment.dart';
import 'package:cashier_app/domain/repositories/payment_repository.dart';
import 'package:cashier_app/features/sales/presentation/checkout_dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:cashier_app/features/common/widgets/sync_banner.dart';
import 'package:go_router/go_router.dart';
import 'package:cashier_app/services/key_value_service.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => SalesBloc(ctx.read<SaleRepository>())..add(const SalesSubscribed()),
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            appBar: AppBar(
              titleSpacing: 16,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.tabSales),
                  const SizedBox(height: 4),
                  Text(
                    l10n.salesAppBarSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  const SyncBanner(),
                  Expanded(
                    child: StreamBuilder<List<Payment>>(
                      stream: context.read<PaymentRepository>().watchAll(),
                      builder: (context, paymentsSnap) {
                        final payments = paymentsSnap.data ?? const <Payment>[];
                        final paymentTotals = <String, int>{};
                        for (final payment in payments) {
                          paymentTotals.update(
                            payment.saleId,
                            (value) => value + payment.amount.amount,
                            ifAbsent: () => payment.amount.amount,
                          );
                        }

                        return BlocBuilder<SalesBloc, SalesState>(
                          builder: (context, state) {
                            if (state.isLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            if (state.items.isEmpty) {
                              return _SalesEmptyState(message: l10n.noSales, description: l10n.salesEmptyDescription);
                            }

                            final totalAmount = state.items.fold<int>(
                              0,
                              (sum, sale) => sum + sale.total.amount,
                            );
                            final outstandingAmount = state.items.fold<int>(
                              0,
                              (sum, sale) =>
                                  sum + (sale.total.amount - (paymentTotals[sale.id] ?? 0)).clamp(0, 1 << 31),
                            );
                            final paidCount = state.items
                                .where((sale) => (sale.total.amount - (paymentTotals[sale.id] ?? 0)) <= 0)
                                .length;

                            final currencyFormat = NumberFormat.decimalPattern(l10n.localeName);

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  child: _SalesSummaryCard(
                                    l10n: l10n,
                                    currencyFormat: currencyFormat,
                                    totalAmount: totalAmount,
                                    outstandingAmount: outstandingAmount,
                                    paidCount: paidCount,
                                    totalCount: state.items.length,
                                  ),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 104),
                                    itemCount: state.items.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                                    itemBuilder: (_, i) {
                                      final sale = state.items[i];
                                      final paid = paymentTotals[sale.id] ?? 0;
                                      final remaining = (sale.total.amount - paid).clamp(0, 1 << 31);
                                      void deleteSale() {
                                        context.read<SalesBloc>().add(SaleDeleted(sale.id));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(l10n.settingsSyncDeleted),
                                            action: SnackBarAction(
                                              label: l10n.undo,
                                              onPressed: () {
                                                context.read<SalesBloc>().add(SaleAdded(sale));
                                              },
                                            ),
                                          ),
                                        );
                                      }

                                      return Dismissible(
                                        key: ValueKey(sale.id),
                                        direction: DismissDirection.endToStart,
                                        background: _DismissibleBackground(label: l10n.settingsSyncDeleted),
                                        confirmDismiss: (_) async {
                                          deleteSale();
                                          return true;
                                        },
                                        child: _SaleCard(
                                          sale: sale,
                                          paid: paid,
                                          remaining: remaining,
                                          currencyFormat: currencyFormat,
                                          l10n: l10n,
                                          onTap: () =>
                                              context.pushNamed('sale_detail', pathParameters: {'id': sale.id}),
                                          onReceivePayment: remaining > 0
                                              ? () async {
                                                  final result = await showDialog<CheckoutResult>(
                                                    context: context,
                                                    builder: (_) => CheckoutDialog(total: remaining),
                                                  );
                                                  if (result == null) return;
                                                  final payment = Payment(
                                                    id: const Uuid().v4(),
                                                    saleId: sale.id,
                                                    method:
                                                        result.method == PaymentMethod.cash ? 'cash' : 'transfer',
                                                    amount: MoneyRiel(result.tendered),
                                                  );
                                                  await context.read<PaymentRepository>().add(payment);
                                                  if (result.reference != null && result.reference!.isNotEmpty) {
                                                    await KeyValueService.set(
                                                      'payment_ref_${payment.id}',
                                                      result.reference!,
                                                    );
                                                  }
                                                  final change = result.tendered - remaining;
                                                  final msg = change >= 0
                                                      ? l10n.saleCompletedChange(
                                                          '៛${currencyFormat.format(change)}',
                                                        )
                                                      : l10n.saleCompletedRemaining(
                                                          '៛${currencyFormat.format(-change)}',
                                                        );
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(content: Text(msg)));
                                                }
                                              : null,
                                          onDelete: deleteSale,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                final sale = Sale(
                  id: const Uuid().v4(),
                  createdAt: DateTime.now(),
                  total: const MoneyRiel(2000),
                );
                context.read<SalesBloc>().add(SaleAdded(sale));
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.salesNewSale),
            ),
          );
        },
      ),
    );
  }
}

class _SalesSummaryCard extends StatelessWidget {
  const _SalesSummaryCard({
    required this.l10n,
    required this.currencyFormat,
    required this.totalAmount,
    required this.outstandingAmount,
    required this.paidCount,
    required this.totalCount,
  });

  final AppLocalizations l10n;
  final NumberFormat currencyFormat;
  final int totalAmount;
  final int outstandingAmount;
  final int paidCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.salesSummaryTotal,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '៛${currencyFormat.format(totalAmount)}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SummaryTile(
                label: l10n.salesSummaryOutstanding,
                value: '៛${currencyFormat.format(outstandingAmount)}',
              ),
              const SizedBox(width: 16),
              _SummaryTile(
                label: l10n.salesSummaryCompleted,
                value: '$paidCount/$totalCount',
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  const _SaleCard({
    required this.sale,
    required this.paid,
    required this.remaining,
    required this.currencyFormat,
    required this.l10n,
    required this.onTap,
    required this.onDelete,
    this.onReceivePayment,
  });

  final Sale sale;
  final int paid;
  final int remaining;
  final NumberFormat currencyFormat;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Future<void> Function()? onReceivePayment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createdAt = DateFormat.yMMMd(l10n.localeName).add_jm().format(sale.createdAt);
    final totalLabel = '៛${currencyFormat.format(sale.total.amount)}';
    final paidLabel = '៛${currencyFormat.format(paid)}';
    final remainingLabel = '៛${currencyFormat.format(remaining)}';
    final isPaid = remaining <= 0;
    final statusLabel = isPaid ? l10n.paid : l10n.salesStatusOutstanding;
    final statusColor = isPaid ? theme.colorScheme.primaryContainer : theme.colorScheme.errorContainer;
    final statusTextColor = isPaid
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.error;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.primaryContainer,
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${sale.id.substring(0, 6).toUpperCase()}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          createdAt,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: statusTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.salesCardTotal,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          totalLabel,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.paid,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          paidLabel,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.colorScheme.surfaceContainerHigh,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.balance}:',
                      style: theme.textTheme.labelLarge,
                    ),
                    Text(
                      remainingLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isPaid ? theme.colorScheme.primary : theme.colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (onReceivePayment != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => onReceivePayment!(),
                        icon: const Icon(Icons.payments_outlined),
                        label: Text(l10n.receivePayment),
                      ),
                    )
                  else
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.visibility_outlined),
                        label: Text(l10n.salesViewDetails),
                      ),
                    ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l10n.salesDeleteTooltip,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SalesEmptyState extends StatelessWidget {
  const _SalesEmptyState({required this.message, required this.description});

  final String message;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DismissibleBackground extends StatelessWidget {
  const _DismissibleBackground({required this.label});

  final String label;

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
            label,
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
