import 'package:flutter/material.dart';
import 'package:cashier_app/domain/entities/product.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier_app/domain/repositories/product_repository.dart';

class ProductFormPage extends StatefulWidget {
  final Product? existing;
  const ProductFormPage({super.key, this.existing});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _sku;
  late final TextEditingController _unitCost;
  late final TextEditingController _price;
  late final TextEditingController _stock;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _sku = TextEditingController(text: widget.existing?.sku ?? '');
    _unitCost = TextEditingController(text: widget.existing?.unitCost.amount.toString() ?? '');
    _price = TextEditingController(text: widget.existing?.price.amount.toString() ?? '');
    _stock = TextEditingController(text: widget.existing?.stock.toString() ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _unitCost.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _nonNegativeInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = int.tryParse(v);
    if (n == null || n < 0) return 'Must be >= 0';
    return null;
  }

  String? _skuRule(String? v) {
    final base = _required(v);
    if (base != null) return base;
    final s = v!.trim();
    final ok = RegExp(r'^[A-Za-z0-9_-]{3,32}\$?').hasMatch(s);
    if (!ok) return '3-32 chars, letters/digits/_-';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final unit = int.parse(_unitCost.text.trim());
    final price = int.parse(_price.text.trim());
    if (price < unit) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Price must be >= Unit cost')));
      return;
    }

    // Duplicate SKU validation against Isar via repository
    final repo = context.read<ProductRepository>();
    final inputSku = _sku.text.trim();
    final existing = await repo.getBySku(inputSku);
    final editingId = widget.existing?.id;
    if (existing != null && existing.id != editingId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SKU already exists')));
      return;
    }

    final product = Product(
      id: editingId ?? const Uuid().v4(),
      name: _name.text.trim(),
      sku: inputSku,
      unitCost: MoneyRiel(unit),
      price: MoneyRiel(price),
      stock: int.parse(_stock.text.trim()),
    );
    Navigator.of(context).pop(product);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.existing == null ? 'Add Product' : 'Edit Product', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name'), validator: _required),
                TextFormField(controller: _sku, decoration: const InputDecoration(labelText: 'SKU'), validator: _skuRule),
                TextFormField(controller: _unitCost, decoration: const InputDecoration(labelText: 'Unit cost (៛)'), keyboardType: TextInputType.number, validator: _nonNegativeInt),
                TextFormField(controller: _price, decoration: const InputDecoration(labelText: 'Price (៛)'), keyboardType: TextInputType.number, validator: _nonNegativeInt),
                TextFormField(controller: _stock, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number, validator: _nonNegativeInt),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
