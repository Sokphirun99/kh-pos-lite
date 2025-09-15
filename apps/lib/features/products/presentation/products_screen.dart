import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier_app/features/products/bloc/products_bloc.dart';
import 'package:cashier_app/domain/entities/product.dart';
import 'package:cashier_app/domain/repositories/product_repository.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:cashier_app/features/sync/bloc/sync_bloc.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ProductsBloc(ctx.read<ProductRepository>())..add(const ProductsSubscribed()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Products')),
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
            ),
            Expanded(
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  if (state.isLoading) return const Center(child: CircularProgressIndicator());
                  if (state.error != null) return Center(child: Text(state.error!));
                  final l10n = AppLocalizations.of(context);
                  if (state.items.isEmpty) return Center(child: Text(l10n?.noProducts ?? 'No products'));
                  return ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (_, i) {
                      final p = state.items[i];
                      return Dismissible(
                        key: ValueKey(p.id),
                        background: Container(color: Colors.red),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          context.read<ProductsBloc>().add(ProductDeleted(p.id));
                          final l10n = AppLocalizations.of(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n?.settingsSyncDeleted ?? 'Deleted'),
                              action: SnackBarAction(
                                label: l10n?.undo ?? 'UNDO',
                                onPressed: () {
                                  context.read<ProductsBloc>().add(ProductAdded(p));
                                },
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(p.name),
                          subtitle: Text('៛${p.price.amount}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              context.read<ProductsBloc>().add(ProductDeleted(p.id));
                              final l10n = AppLocalizations.of(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n?.settingsSyncDeleted ?? 'Deleted'),
                                  action: SnackBarAction(
                                    label: l10n?.undo ?? 'UNDO',
                                    onPressed: () {
                                      context.read<ProductsBloc>().add(ProductAdded(p));
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
            final id = const Uuid().v4();
            context.read<ProductsBloc>().add(
                  ProductAdded(Product(id: id, name: 'Item $id', price: const MoneyRiel(1000))),
                );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
