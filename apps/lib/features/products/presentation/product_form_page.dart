import 'package:flutter/material.dart';
import 'package:cashier_app/domain/entities/product.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier_app/domain/repositories/product_repository.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:cashier_app/l10n/app_localizations_en.dart';
import 'package:cashier_app/features/common/widgets/app_form_styles.dart';
import 'package:cashier_app/features/common/widgets/section_header.dart';

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
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _sku = TextEditingController(text: existing?.sku ?? '');
    _unitCost = TextEditingController(
      text: existing != null ? existing.unitCost.amount.toString() : '',
    );
    _price = TextEditingController(
      text: existing != null ? existing.price.amount.toString() : '',
    );
    _stock = TextEditingController(
      text: existing != null ? existing.stock.toString() : '',
    );
    _note = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _unitCost.dispose();
    _price.dispose();
    _stock.dispose();
    _note.dispose();
    super.dispose();
  }

  AppLocalizations _l10n(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizationsEn();
  }

  String? _required(String? v) {
    final l10n = _l10n(context);
    return (v == null || v.trim().isEmpty) ? l10n.formRequired : null;
  }

  String? _nonNegativeInt(String? v) {
    final l10n = _l10n(context);
    if (v == null || v.trim().isEmpty) return l10n.formRequired;
    final n = int.tryParse(v);
    if (n == null || n < 0) return l10n.formNonNegative;
    return null;
  }

  String? _skuRule(String? v) {
    final base = _required(v);
    if (base != null) return base;
    final s = v!.trim();
    final ok = RegExp(r'^[A-Za-z0-9_-]{3,32}$').hasMatch(s);
    if (!ok) return _l10n(context).itemsSkuFormat;
    return null;
  }

  bool get _isEditing => widget.existing != null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final unit = int.parse(_unitCost.text.trim());
    final price = int.parse(_price.text.trim());
    if (price < unit) {
      final l10n = _l10n(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.itemsPriceValidation)));
      return;
    }

    // Duplicate SKU validation against Isar via repository
    final repo = context.read<ProductRepository>();
    final inputSku = _sku.text.trim();
    final existing = await repo.getBySku(inputSku);
    final editingId = widget.existing?.id;
    if (existing != null && existing.id != editingId) {
      final l10n = _l10n(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.itemsSkuExists)));
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
    final l10n = _l10n(context);
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(
          _isEditing ? l10n.itemsFormTitleEdit : l10n.itemsFormTitleCreate,
        ),
        actions: [TextButton(onPressed: _save, child: Text(l10n.commonDone))],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: viewInsets.bottom + 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(l10n.itemsFormSectionBasicInfo),
                        TextFormField(
                          controller: _name,
                          decoration: AppFormStyles.fieldDecoration(
                            context,
                            label: l10n.itemsFieldName,
                          ),
                          validator: _required,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _sku,
                          decoration: AppFormStyles.fieldDecoration(
                            context,
                            label: l10n.itemsFieldCode,
                          ),
                          validator: _skuRule,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _unitCost,
                          decoration: AppFormStyles.fieldDecoration(
                            context,
                            label: l10n.itemsFieldUnitCost,
                          ),
                          keyboardType: TextInputType.number,
                          validator: _nonNegativeInt,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _price,
                          decoration: AppFormStyles.fieldDecoration(
                            context,
                            label: l10n.itemsFieldPrice,
                          ),
                          keyboardType: TextInputType.number,
                          validator: _nonNegativeInt,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _stock,
                          decoration: AppFormStyles.fieldDecoration(
                            context,
                            label: l10n.itemsFieldStock,
                          ),
                          keyboardType: TextInputType.number,
                          validator: _nonNegativeInt,
                          textInputAction: TextInputAction.done,
                        ),
                        SectionHeader(l10n.itemsFormSectionNote),
                        TextFormField(
                          controller: _note,
                          minLines: 3,
                          maxLines: 5,
                          decoration: AppFormStyles.fieldDecoration(
                            context,
                            label: l10n.itemsFieldNoteHint,
                          ),
                        ),
                        SectionHeader(l10n.itemsFormSectionImage),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
                            label: Text(l10n.itemsAddImage),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              foregroundColor: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
