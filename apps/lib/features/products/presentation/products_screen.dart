import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier_app/features/products/bloc/products_bloc.dart';
import 'package:cashier_app/domain/entities/product.dart';
import 'package:cashier_app/domain/repositories/product_repository.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:cashier_app/features/common/widgets/empty_placeholder.dart';
import 'package:cashier_app/features/common/widgets/sync_banner.dart';
import 'package:cashier_app/services/key_value_service.dart';
import 'package:cashier_app/features/common/widgets/skeleton_loader.dart';
import 'package:go_router/go_router.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String query = '';
  bool skuOnly = false;

  Future<void> _openForm(BuildContext context, {Product? existing}) async {
    final result = existing == null
        ? await context.pushNamed<Product>('product_new')
        : await context.pushNamed<Product>('product_edit', pathParameters: {'id': existing.id}, extra: existing);
    if (result == null) return;
    final bloc = context.read<ProductsBloc>();
    if (existing == null) {
      bloc.add(ProductAdded(result));
    } else {
      bloc.add(ProductUpdated(result));
    }
  }

  Widget _emptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyPlaceholder(
      icon: Icons.inventory_2_outlined,
      title: l10n.itemsEmptyTitle,
      message: l10n.itemsEmptySubtitle,
      actionLabel: l10n.itemsCreateButton,
      onActionPressed: () => _openForm(context),
    );
  }

  Widget _buildProductTile(BuildContext context, Product product, {required bool lowStock}) {
    final theme = Theme.of(context);
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
    );
    final l10n = AppLocalizations.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _openForm(context, existing: product),
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
                        Text(product.name, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text('SKU: ${product.sku}', style: subtitleStyle),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      context.read<ProductsBloc>().add(ProductDeleted(product.id));
                      final snackL10n = AppLocalizations.of(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(snackL10n.settingsSyncDeleted),
                          action: SnackBarAction(
                            label: snackL10n.undo,
                            onPressed: () {
                              context.read<ProductsBloc>().add(ProductAdded(product));
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _infoChip(context, l10n.itemsStockChip(product.stock)),
                  _infoChip(context, '៛${product.price.amount}'),
                  if (lowStock)
                    Chip(
                      label: Text(l10n.lowStock),
                      backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.3),
                      labelStyle: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.error),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(BuildContext context, String text) => Chip(label: Text(text));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (ctx) => ProductsBloc(ctx.read<ProductRepository>())..add(const ProductsSubscribed()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.tabItems),
          actions: [
            IconButton(
              icon: const Icon(Icons.inventory_2_outlined),
              tooltip: l10n.itemsAdjustStockTooltip,
              onPressed: () => context.pushNamed('stock_adjustments'),
            ),
          ],
        ),
        body: Column(
          children: [
            const SyncBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBar(
                    hintText: l10n.itemsSearchHint,
                    leading: const Icon(Icons.search),
                    onChanged: (v) => setState(() => query = v.trim().toLowerCase()),
                  ),
                  const SizedBox(height: 12),
                  FilterChip(
                    label: Text(l10n.itemsSkuOnlyFilter),
                    selected: skuOnly,
                    onSelected: (v) => setState(() => skuOnly = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  if (state.isLoading) return const ListSkeleton();
                  if (state.error != null) return Center(child: Text(state.error!));
                  final items = state.items
                      .where((p) {
                        if (query.isEmpty) return true;
                        final name = p.name.toLowerCase();
                        final sku = p.sku.toLowerCase();
                        return skuOnly ? sku.contains(query) : (name.contains(query) || sku.contains(query));
                      })
                      .toList();
                  if (items.isEmpty) return _emptyState(context);
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) {
                      final p = items[i];
                      final threshold = KeyValueService.get<int>('low_stock_threshold') ?? 5;
                      final lowStock = p.stock <= threshold;
                      return Dismissible(
                        key: ValueKey(p.id),
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          context.read<ProductsBloc>().add(ProductDeleted(p.id));
                          final snackL10n = AppLocalizations.of(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(snackL10n.settingsSyncDeleted),
                              action: SnackBarAction(
                                label: snackL10n.undo,
                                onPressed: () {
                                  context.read<ProductsBloc>().add(ProductAdded(p));
                                },
                              ),
                            ),
                          );
                        },
                        child: _buildProductTile(context, p, lowStock: lowStock),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openForm(context),
          icon: const Icon(Icons.add),
          label: Text(l10n.itemsCreateButton),
        ),
      ),
    );
  }
}
