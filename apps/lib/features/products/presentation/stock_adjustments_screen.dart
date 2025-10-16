import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier_app/features/products/bloc/products_bloc.dart';
import 'package:cashier_app/domain/repositories/product_repository.dart';
import 'package:cashier_app/l10n/app_localizations.dart';

class StockAdjustmentsScreen extends StatelessWidget {
  const StockAdjustmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          ProductsBloc(ctx.read<ProductRepository>())
            ..add(const ProductsSubscribed()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).adjustStockTitle),
        ),
        body: BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            if (state.isLoading)
              return const Center(child: CircularProgressIndicator());
            if (state.error != null) return Center(child: Text(state.error!));
            final items = state.items;
            if (items.isEmpty)
              return Center(
                child: Text(AppLocalizations.of(context).noProducts),
              );
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final p = items[i];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text(
                    '${AppLocalizations.of(context).stockLabel}: ${p.stock} • SKU: ${p.sku}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: AppLocalizations.of(context).decrease,
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          final newStock = (p.stock - 1).clamp(0, 1 << 31);
                          context.read<ProductsBloc>().add(
                            ProductUpdated(p.copyWith(stock: newStock)),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: AppLocalizations.of(context).increase,
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final newStock = (p.stock + 1).clamp(0, 1 << 31);
                          context.read<ProductsBloc>().add(
                            ProductUpdated(p.copyWith(stock: newStock)),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: AppLocalizations.of(context).setStock,
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final controller = TextEditingController(
                            text: p.stock.toString(),
                          );
                          final value = await showDialog<int>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(
                                AppLocalizations.of(context).setStock,
                              ),
                              content: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text(
                                    AppLocalizations.of(context).cancel,
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    final n = int.tryParse(
                                      controller.text.trim(),
                                    );
                                    if (n == null || n < 0) {
                                      Navigator.pop(ctx);
                                    } else {
                                      Navigator.pop(ctx, n);
                                    }
                                  },
                                  child: Text(AppLocalizations.of(context).ok),
                                ),
                              ],
                            ),
                          );
                          if (value != null) {
                            context.read<ProductsBloc>().add(
                              ProductUpdated(p.copyWith(stock: value)),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
