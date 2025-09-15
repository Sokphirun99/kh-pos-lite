import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/payments_bloc.dart';
import 'package:cashier_app/domain/repositories/payment_repository.dart';
import 'package:cashier_app/domain/entities/payment.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';
import 'package:uuid/uuid.dart';
import 'package:cashier_app/features/sync/bloc/sync_bloc.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:cashier_app/features/common/widgets/sync_banner.dart';
import 'package:cashier_app/services/key_value_service.dart';
import 'package:flutter/services.dart';

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
          const SyncBanner(),
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
                    final ref = KeyValueService.get<String>('payment_ref_${p.id}');
                    return Dismissible(
                      key: ValueKey(p.id),
                      background: Container(color: Colors.red),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        final l10n = AppLocalizations.of(context);
                        final prevRef = ref;
                        context.read<PaymentsBloc>().add(PaymentDeleted(p.id));
                        if (prevRef != null && prevRef.isNotEmpty) {
                          KeyValueService.remove('payment_ref_${p.id}');
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n?.settingsSyncDeleted ?? 'Deleted'),
                            action: SnackBarAction(
                              label: l10n?.undo ?? 'UNDO',
                              onPressed: () async {
                                context.read<PaymentsBloc>().add(PaymentAdded(p));
                                if (prevRef != null && prevRef.isNotEmpty) {
                                  await KeyValueService.set('payment_ref_${p.id}', prevRef);
                                }
                              },
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text('Payment ${p.id}'),
                        subtitle: Text(ref == null || ref.isEmpty
                            ? '៛${p.amount.amount} (${p.method})'
                            : '៛${p.amount.amount} (${p.method}) • ${AppLocalizations.of(context).txRefLabel(ref)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (ref != null && ref.isNotEmpty)
                              IconButton(
                                tooltip: AppLocalizations.of(context).aboutCopied,
                                icon: const Icon(Icons.copy),
                                onPressed: () async {
                                  await Clipboard.setData(ClipboardData(text: ref));
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(AppLocalizations.of(context).aboutCopied)),
                                    );
                                  }
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                final l10n = AppLocalizations.of(context);
                                final prevRef = ref;
                                context.read<PaymentsBloc>().add(PaymentDeleted(p.id));
                                if (prevRef != null && prevRef.isNotEmpty) {
                                  KeyValueService.remove('payment_ref_${p.id}');
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n?.settingsSyncDeleted ?? 'Deleted'),
                                    action: SnackBarAction(
                                      label: l10n?.undo ?? 'UNDO',
                                      onPressed: () async {
                                        context.read<PaymentsBloc>().add(PaymentAdded(p));
                                        if (prevRef != null && prevRef.isNotEmpty) {
                                          await KeyValueService.set('payment_ref_${p.id}', prevRef);
                                        }
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
