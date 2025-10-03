import 'package:cashier_app/domain/entities/product.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';
import 'package:cashier_app/features/products/bloc/products_bloc.dart';
import 'package:cashier_app/features/sales/bloc/cart_bloc.dart';
import 'package:cashier_app/features/sales/bloc/cart_event.dart';
import 'package:cashier_app/features/sales/bloc/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier_app/domain/repositories/product_repository.dart';
import 'package:cashier_app/domain/repositories/sale_repository.dart';
import 'package:cashier_app/features/sales/bloc/sales_bloc.dart';
import 'package:cashier_app/domain/entities/sale.dart';
import 'package:uuid/uuid.dart';
import 'package:cashier_app/features/sales/presentation/checkout_dialog.dart';
import 'package:cashier_app/domain/entities/payment.dart';
import 'package:cashier_app/features/payments/bloc/payments_bloc.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:cashier_app/services/key_value_service.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  String query = '';
  bool skuOnly = false;
  final TextEditingController _discountCtrl = TextEditingController();

  @override
  void dispose() {
    _discountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProductsBloc(context.read<ProductRepository>())..add(const ProductsSubscribed())),
        BlocProvider(create: (_) => CartBloc()),
        BlocProvider(create: (_) => SalesBloc(context.read<SaleRepository>())..add(const SalesSubscribed())),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sell'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear Cart',
              onPressed: () => context.read<CartBloc>().add(const CartCleared()),
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(92),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SearchBar(
                    hintText: 'Search products',
                    leading: const Icon(Icons.search),
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
            Expanded(
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  if (state.isLoading) return const Center(child: CircularProgressIndicator());
                  if (state.error != null) return Center(child: Text(state.error!));
                  final items = state.items.where((p) {
                    if (query.isEmpty) return true;
                    final name = p.name.toLowerCase();
                    final sku = p.sku.toLowerCase();
                    return skuOnly ? sku.contains(query) : (name.contains(query) || sku.contains(query));
                  }).toList();
                  if (items.isEmpty) return const Center(child: Text('No products'));
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.9,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _ProductTile(p: items[i]),
                  );
                },
              ),
            ),
            const _CartPanel(),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product p;
  const _ProductTile({required this.p});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (p.stock <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).outOfStock)),
          );
          return;
        }
        final cart = context.read<CartBloc>().state;
        final existing = cart.items.firstWhere(
          (e) => e.product.id == p.id,
          orElse: () => CartLine(product: p, quantity: 0),
        );
        if (existing.quantity >= p.stock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).insufficientStock)),
          );
          return;
        }
        context.read<CartBloc>().add(CartItemAdded(p));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(p.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  Builder(builder: (context) {
                    final threshold = KeyValueService.get<int>('low_stock_threshold') ?? 5;
                    final low = p.stock <= threshold;
                    if (!low) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Chip(
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        label: Text(AppLocalizations.of(context).lowStock),
                        backgroundColor: Theme.of(context).colorScheme.errorContainer,
                        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    );
                  })
                ],
              ),
              const SizedBox(height: 4),
              Text('SKU: ${p.sku}', style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text('៛${p.price.amount}', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartPanel extends StatefulWidget {
  const _CartPanel();

  @override
  State<_CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends State<_CartPanel> {
  final TextEditingController _discount = TextEditingController(text: '0');

  @override
  void dispose() {
    _discount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cart) {
        final rows = cart.items;
        return Material(
          elevation: 8,
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart),
                    const SizedBox(width: 8),
                    Text('Cart', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    Text('Items: ${rows.fold<int>(0, (s, e) => s + e.quantity)}'),
                  ],
                ),
                const SizedBox(height: 8),
                if (rows.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No items yet. Tap a product to add.'),
                  )
                else
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      itemCount: rows.length,
                      itemBuilder: (_, i) {
                        final it = rows[i];
                        final over = it.quantity > it.product.stock;
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(it.product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: over
                              ? Text('${AppLocalizations.of(context).exceedsStock} • SKU: ${it.product.sku}',
                                  style: const TextStyle(color: Colors.red))
                              : Text('SKU: ${it.product.sku}'),
                          trailing: SizedBox(
                            width: 160,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => context.read<CartBloc>().add(CartDecremented(it.product.id)),
                                ),
                                Text('${it.quantity}')
                                    ,
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    if (it.quantity >= it.product.stock) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(AppLocalizations.of(context).insufficientStock)),
                                      );
                                      return;
                                    }
                                    context.read<CartBloc>().add(CartIncremented(it.product.id));
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text('៛${it.lineTotal}'),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => context.read<CartBloc>().add(CartItemRemoved(it.product.id)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const Divider(),
                Row(
                  children: [
                    const Text('Subtotal'),
                    const Spacer(),
                    Text('៛${cart.subtotal}')
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SegmentedButton<DiscountMode>(
                      segments: const [
                        ButtonSegment(value: DiscountMode.percent, label: Text('%')),
                        ButtonSegment(value: DiscountMode.amount, label: Text('KHR')),
                      ],
                      selected: {cart.discountMode},
                      onSelectionChanged: (s) {
                        context.read<CartBloc>().add(CartDiscountModeSet(s.first));
                        _discount.text = cart.discountValue.toString();
                      },
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _discount,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context).discount, isDense: true),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final value = int.tryParse(v) ?? 0;
                          context.read<CartBloc>().add(CartDiscountValueSet(value));
                        },
                      ),
                    ),
                    const Spacer(),
                    Text('-៛${cart.discountAmount}')
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Total', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    Text('៛${cart.total}', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.read<CartBloc>().add(const CartCleared()),
                        child: Text(AppLocalizations.of(context).voidSale),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.check),
                        label: Text(AppLocalizations.of(context).checkoutTitle),
                        onPressed: cart.items.isEmpty
                            ? null
                            : () async {
                                // Validate stock before checkout
                                final repo = context.read<ProductRepository>();
                                final insufficient = <String>[];
                                for (final line in cart.items) {
                                  final latest = await repo.getById(line.product.id) ?? line.product;
                                  if (line.quantity > latest.stock) {
                                    insufficient.add(AppLocalizations.of(context).notEnoughStockFor(latest.name, latest.stock));
                                  }
                                }
                                final allowOversell = (KeyValueService.get<bool>('allow_oversell') ?? false);
                                if (insufficient.isNotEmpty && !allowOversell) {
                                  if (context.mounted) {
                                    await showDialog<void>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text(AppLocalizations.of(context).insufficientStock),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: insufficient.map((m) => Text('• $m')).toList(),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: Text(AppLocalizations.of(context).ok),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                  return;
                                }
                                if (insufficient.isNotEmpty && allowOversell) {
                                  final proceed = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text(AppLocalizations.of(context).insufficientStock),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: insufficient.map((m) => Text('• $m')).toList(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text(AppLocalizations.of(context).cancel),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: Text(AppLocalizations.of(context).ok),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (proceed != true) return;
                                }

                                final result = await showDialog<CheckoutResult>(
                                  context: context,
                                  builder: (_) => CheckoutDialog(total: cart.total),
                                );
                                if (result == null) return;

                                final sale = Sale(
                                  id: const Uuid().v4(),
                                  createdAt: DateTime.now(),
                                  total: MoneyRiel(cart.total),
                                );

                                // Persist sale
                                context.read<SalesBloc>().add(SaleAdded(sale));

                                // Persist payment
                                final pay = Payment(
                                  id: const Uuid().v4(),
                                  saleId: sale.id,
                                  method: result.method == PaymentMethod.cash ? 'cash' : 'transfer',
                                  amount: MoneyRiel(result.tendered),
                                );
                                context.read<PaymentsBloc>().add(PaymentAdded(pay));
                                if (result.reference != null && result.reference!.isNotEmpty) {
                                  await KeyValueService.set('payment_ref_${pay.id}', result.reference!);
                                }
                                // Deduct stock per cart line
                                final productRepo = context.read<ProductRepository>();
                                for (final line in context.read<CartBloc>().state.items) {
                                  final p = line.product;
                                  final newStock = (p.stock - line.quantity).clamp(0, 1 << 31);
                                  final updated = p.copyWith(stock: newStock);
                                  await productRepo.update(updated);
                                }
                                
                                if (mounted) {
                                  final change = result.tendered - cart.total;
                                  final l10n = AppLocalizations.of(context);
                                  context.read<CartBloc>().add(const CartCleared());
                                  final msg = change >= 0
                                      ? l10n.saleCompletedChange('៛$change')
                                      : l10n.saleCompletedRemaining('៛${(-change)}');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(msg)),
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
