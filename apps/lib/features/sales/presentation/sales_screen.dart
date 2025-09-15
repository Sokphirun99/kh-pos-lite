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
import 'package:cashier_app/features/sync/bloc/sync_bloc.dart';
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
      child: Scaffold(
      appBar: AppBar(title: const Text('Sales')),
      body: Column(
        children: [
          const SyncBanner(),
          Expanded(
            child: StreamBuilder<List<Payment>>(
              stream: context.read<PaymentRepository>().watchAll(),
              builder: (context, paymentsSnap) {
                final payments = paymentsSnap.data ?? const <Payment>[];
                return BlocBuilder<SalesBloc, SalesState>(
                  builder: (context, state) {
                    if (state.isLoading) return const Center(child: CircularProgressIndicator());
                    final l10n = AppLocalizations.of(context);
                    if (state.items.isEmpty) return Center(child: Text(l10n?.noSales ?? 'No sales'));
                    return ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (_, i) {
                        final s = state.items[i];
                        final paid = payments
                            .where((p) => p.saleId == s.id)
                            .fold<int>(0, (sum, p) => sum + p.amount.amount);
                        final remaining = (s.total.amount - paid).clamp(0, 1 << 31);

                        return Dismissible(
                          key: ValueKey(s.id),
                          background: Container(color: Colors.red),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            context.read<SalesBloc>().add(SaleDeleted(s.id));
                            final l10n = AppLocalizations.of(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n?.settingsSyncDeleted ?? 'Deleted'),
                                action: SnackBarAction(
                                  label: l10n?.undo ?? 'UNDO',
                                  onPressed: () {
                                    context.read<SalesBloc>().add(SaleAdded(s));
                                  },
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text('Sale ${s.id}'),
                            subtitle: Text('៛${s.total.amount} • ${l10n?.balance ?? 'Balance'}: ៛$remaining'),
                            onTap: () => context.pushNamed('sale_detail', pathParameters: {'id': s.id}),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (remaining > 0)
                                  OutlinedButton(
                                    onPressed: () async {
                                      final result = await showDialog<CheckoutResult>(
                                        context: context,
                                        builder: (_) => CheckoutDialog(total: remaining),
                                      );
                                      if (result == null) return;
                                      final payment = Payment(
                                        id: const Uuid().v4(),
                                        saleId: s.id,
                                        method: result.method == PaymentMethod.cash ? 'cash' : 'transfer',
                                        amount: MoneyRiel(result.tendered),
                                      );
                                      await context.read<PaymentRepository>().add(payment);
                                      if (result.reference != null && result.reference!.isNotEmpty) {
                                        await KeyValueService.set('payment_ref_${payment.id}', result.reference!);
                                      }
                                      final change = result.tendered - remaining;
                                      final msg = change >= 0
                                          ? AppLocalizations.of(context).saleCompletedChange('៛$change')
                                          : AppLocalizations.of(context).saleCompletedRemaining('៛${(-change)}');
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                                    },
                                    child: Text(l10n?.receivePayment ?? 'Receive Payment'),
                                  )
                                else
                                  const Icon(Icons.check_circle, color: Colors.green),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    context.read<SalesBloc>().add(SaleDeleted(s.id));
                                    final l10n = AppLocalizations.of(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n?.settingsSyncDeleted ?? 'Deleted'),
                                        action: SnackBarAction(
                                          label: l10n?.undo ?? 'UNDO',
                                          onPressed: () {
                                            context.read<SalesBloc>().add(SaleAdded(s));
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final sale = Sale(id: const Uuid().v4(), createdAt: DateTime.now(), total: const MoneyRiel(2000));
          context.read<SalesBloc>().add(SaleAdded(sale));
        },
        child: const Icon(Icons.add),
      ),
      ),
    );
  }
}
