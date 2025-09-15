import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier_app/features/products/bloc/products_bloc.dart';
import 'package:cashier_app/domain/entities/product.dart';
import 'package:cashier_app/domain/repositories/product_repository.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';
import 'package:uuid/uuid.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:cashier_app/features/common/widgets/sync_banner.dart';
import 'package:cashier_app/features/settings/bloc/feature_flags_cubit.dart';
import 'product_form_page.dart';
import 'package:cashier_app/services/key_value_service.dart';
import 'package:go_router/go_router.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String query = '';
  bool skuOnly = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ProductsBloc(ctx.read<ProductRepository>())..add(const ProductsSubscribed()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Products'),
          actions: [
            IconButton(
              icon: const Icon(Icons.point_of_sale),
              tooltip: 'Sell',
              onPressed: () => context.pushNamed('sell'),
            ),
            IconButton(
              icon: const Icon(Icons.inventory_2),
              tooltip: 'Adjust Stock',
              onPressed: () => context.pushNamed('stock_adjustments'),
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(96),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by name or SKU',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => query = v.trim().toLowerCase()),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilterChip(
                      label: const Text('Search SKU only'),
                      selected: skuOnly,
                      onSelected: (v) => setState(() => skuOnly = v),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            const SyncBanner(),
            Expanded(
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  if (state.isLoading) return const Center(child: CircularProgressIndicator());
                  if (state.error != null) return Center(child: Text(state.error!));
                  final l10n = AppLocalizations.of(context);
                  final items = state.items
                      .where((p) {
                        if (query.isEmpty) return true;
                        final name = p.name.toLowerCase();
                        final sku = p.sku.toLowerCase();
                        return skuOnly ? sku.contains(query) : (name.contains(query) || sku.contains(query));
                      })
                      .toList();
                  if (items.isEmpty) return Center(child: Text(l10n?.noProducts ?? 'No products'));
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final p = items[i];
                      final threshold = KeyValueService.get<int>('low_stock_threshold') ?? 5;
                      final lowStock = p.stock <= threshold;
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
                          onTap: () async {
                            final updated = await showModalBottomSheet<Product>(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => ProductFormPage(existing: p),
                            );
                            if (updated != null) {
                              context.read<ProductsBloc>().add(ProductUpdated(updated));
                            }
                          },
                          title: Row(
                            children: [
                              Expanded(child: Text(p.name)),
                              if (lowStock)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Chip(
                                    label: Text(AppLocalizations.of(context).lowStock),
                                    backgroundColor: Colors.orangeAccent.withOpacity(0.7),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text('SKU: ${p.sku}  •  Stock: ${p.stock}  •  ៛${p.price.amount}'),
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
          onPressed: () async {
            final created = await showModalBottomSheet<Product>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const ProductFormPage(),
            );
            if (created != null) {
              context.read<ProductsBloc>().add(ProductAdded(created));
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
