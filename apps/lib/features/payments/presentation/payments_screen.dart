import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/payments_bloc.dart';
import 'package:cashier_app/domain/repositories/payment_repository.dart';
import 'package:cashier_app/domain/entities/payment.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';
import 'package:uuid/uuid.dart';
import 'package:cashier_app/features/sync/bloc/sync_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => PaymentsBloc(ctx.read<PaymentRepository>())..add(const PaymentsSubscribed()),
      child: Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: Column(
        children: [
          BlocBuilder<FeatureFlagsCubit, FeatureFlagsState>(
            builder: (context, flags) => flags.showSyncBanner
                ? BlocBuilder<SyncBloc, SyncState>(
                    builder: (context, sync) {
                      final l10n = AppLocalizations.of(context);
                      if (sync.isSyncing) {
                        return ListTile(leading: const Icon(Icons.sync), title: Text(l10n?.settingsSyncing ?? 'Syncing...'));
                      }
                      if (sync.error != null) {
                        return ListTile(leading: const Icon(Icons.error, color: Colors.red), title: Text(l10n?.settingsSyncError(sync.error!) ?? 'Sync error: ${sync.error}'));
                      }
                      if (sync.lastSynced != null) {
                        final time = DateFormat.Hm().format(sync.lastSynced!.toLocal());
                        return ListTile(leading: const Icon(Icons.check, color: Colors.green), title: Text(l10n?.lastSyncAt(time) ?? 'Last sync: $time'));
                      }
                      return const SizedBox.shrink();
                    },
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: BlocBuilder<PaymentsBloc, PaymentsState>(
              builder: (context, state) {
                if (state.isLoading) return const Center(child: CircularProgressIndicator());
                final l10n = AppLocalizations.of(context);
                if (state.items.isEmpty) return Center(child: Text(l10n?.noPayments ?? 'No payments'));
                return ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (_, i) {
                    final p = state.items[i];
                    return Dismissible(
                      key: ValueKey(p.id),
                      background: Container(color: Colors.red),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        context.read<PaymentsBloc>().add(PaymentDeleted(p.id));
                        final l10n = AppLocalizations.of(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n?.settingsSyncDeleted ?? 'Deleted'),
                            action: SnackBarAction(
                              label: l10n?.undo ?? 'UNDO',
                              onPressed: () {
                                context.read<PaymentsBloc>().add(PaymentAdded(p));
                              },
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text('Payment ${p.id}'),
                        subtitle: Text('៛${p.amount.amount} (${p.method})'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            context.read<PaymentsBloc>().add(PaymentDeleted(p.id));
                            final l10n = AppLocalizations.of(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n?.settingsSyncDeleted ?? 'Deleted'),
                                action: SnackBarAction(
                                  label: l10n?.undo ?? 'UNDO',
                                  onPressed: () {
                                    context.read<PaymentsBloc>().add(PaymentAdded(p));
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
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
          final pay = Payment(
            id: const Uuid().v4(),
            saleId: 'sale',
            method: 'cash',
            amount: const MoneyRiel(1500),
          );
          context.read<PaymentsBloc>().add(PaymentAdded(pay));
        },
        child: const Icon(Icons.add),
      ),
      ),
    );
  }
}
