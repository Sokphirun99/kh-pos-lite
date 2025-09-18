import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:cashier_app/features/common/widgets/app_form_styles.dart';
import 'package:cashier_app/features/common/widgets/section_header.dart';

class CustomerDraft {
  final String id;
  final String name;
  final String phone;
  final String altPhone;
  final String vatTin;
  final String address;
  final String note;

  const CustomerDraft({
    required this.id,
    required this.name,
    this.phone = '',
    this.altPhone = '',
    this.vatTin = '',
    this.address = '',
    this.note = '',
  });
}

class CustomerFormPage extends StatefulWidget {
  final CustomerDraft? existing;
  const CustomerFormPage({super.key, this.existing});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _altPhone;
  late final TextEditingController _vat;
  late final TextEditingController _address;
  late final TextEditingController _note;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _phone = TextEditingController(text: widget.existing?.phone ?? '');
    _altPhone = TextEditingController(text: widget.existing?.altPhone ?? '');
    _vat = TextEditingController(text: widget.existing?.vatTin ?? '');
    _address = TextEditingController(text: widget.existing?.address ?? '');
    _note = TextEditingController(text: widget.existing?.note ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _altPhone.dispose();
    _vat.dispose();
    _address.dispose();
    _note.dispose();
    super.dispose();
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? AppLocalizations.of(context)!.formRequired : null;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.existing;
    final draft = CustomerDraft(
      id: existing?.id ?? const Uuid().v4(),
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      altPhone: _altPhone.text.trim(),
      vatTin: _vat.text.trim(),
      address: _address.text.trim(),
      note: _note.text.trim(),
    );
    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(_isEditing ? l10n.customersFormTitleEdit : l10n.customersFormTitleCreate),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.commonDone),
          ),
        ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(l10n.customersSectionBasicInfo),
                        TextFormField(
                          controller: _name,
                          decoration: AppFormStyles.fieldDecoration(
                            context,
                            label: l10n.customersFieldFullName,
                          ),
                          validator: _required,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phone,
                          decoration: AppFormStyles.fieldDecoration(
                            context,
                            label: l10n.customersFieldPhone,
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _altPhone,
                          decoration: AppFormStyles.fieldDecoration(
                            context,
                            label: l10n.customersFieldAltPhone,
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _vat,
                          decoration: AppFormStyles.fieldDecoration(
                            context,
                            label: l10n.customersFieldVatTin,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        SectionHeader(l10n.customersSectionAddress),
                        TextFormField(
                          controller: _address,
                          minLines: 3,
                          maxLines: 4,
                          decoration: AppFormStyles.fieldDecoration(
                            context,
                            label: l10n.customersFieldAddressHint,
                          ),
                        ),
                        SectionHeader(l10n.customersSectionNote),
                        TextFormField(
                          controller: _note,
                          minLines: 3,
                          maxLines: 5,
                          decoration: AppFormStyles.fieldDecoration(
                            context,
                            label: l10n.customersFieldNoteHint,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.customersPrivacyHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
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
