import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sales_bloc.dart';
import 'package:cashier_app/domain/repositories/sale_repository.dart';
import 'package:cashier_app/domain/entities/sale.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';
import 'package:uuid/uuid.dart';
import 'package:cashier_app/features/sync/bloc/sync_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

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
            child: BlocBuilder<SalesBloc, SalesState>(
              builder: (context, state) {
                if (state.isLoading) return const Center(child: CircularProgressIndicator());
                final l10n = AppLocalizations.of(context);
                if (state.items.isEmpty) return Center(child: Text(l10n?.noSales ?? 'No sales'));
                return ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (_, i) {
                    final s = state.items[i];
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
                        subtitle: Text('៛${s.total.amount}'),
                        trailing: IconButton(
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
          final sale = Sale(id: const Uuid().v4(), createdAt: DateTime.now(), total: const MoneyRiel(2000));
          context.read<SalesBloc>().add(SaleAdded(sale));
        },
        child: const Icon(Icons.add),
      ),
      ),
    );
  }
}
