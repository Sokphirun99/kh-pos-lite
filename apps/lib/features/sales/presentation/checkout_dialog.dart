import 'package:flutter/material.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'dart:io';
import 'package:cashier_app/services/key_value_service.dart';

enum PaymentMethod { cash, transfer }

class CheckoutResult {
  final PaymentMethod method;
  final int tendered;
  final String? reference; // optional transfer reference
  const CheckoutResult({required this.method, required this.tendered, this.reference});
}

class CheckoutDialog extends StatefulWidget {
  final int total; // in riel
  const CheckoutDialog({super.key, required this.total});

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  PaymentMethod _method = PaymentMethod.cash;
  late final TextEditingController _tenderedCtrl;
  final TextEditingController _refCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tenderedCtrl = TextEditingController(text: widget.total.toString());
  }

  @override
  void dispose() {
    _tenderedCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  int get _tendered => int.tryParse(_tenderedCtrl.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final khqrPath = KeyValueService.get<String>('khqr_image_path');
    final total = widget.total;
    final tendered = _tendered < 0 ? 0 : _tendered;
    final diff = tendered - total;
    final isEnough = tendered >= total;

    return AlertDialog(
      title: Text(l10n.checkoutTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.checkoutTotal),
              const Spacer(),
              Text('៛$total', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<PaymentMethod>(
            segments: [
              ButtonSegment(value: PaymentMethod.cash, label: Text(l10n.checkoutCash), icon: const Icon(Icons.payments)),
              ButtonSegment(value: PaymentMethod.transfer, label: Text(l10n.checkoutTransfer), icon: const Icon(Icons.account_balance)),
            ],
            selected: {_method},
            onSelectionChanged: (s) => setState(() => _method = s.first),
          ),
          const SizedBox(height: 12),
          if (_method == PaymentMethod.transfer && khqrPath != null) ...[
            Text(l10n.checkoutScanKhqr, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(khqrPath), height: 180, fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _tenderedCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.checkoutAmountReceived,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_method == PaymentMethod.transfer) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _refCtrl,
              decoration: InputDecoration(
                labelText: l10n.checkoutTxReference,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Builder(builder: (context) {
            if (_tenderedCtrl.text.trim().isEmpty) {
              return const SizedBox.shrink();
            }
            if (isEnough) {
              return Text('${l10n.checkoutChangeDue}: ៛$diff', style: const TextStyle(color: Colors.green));
            }
            return Text('${l10n.checkoutRemaining}: ៛${diff.abs()}', style: const TextStyle(color: Colors.red));
          })
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop<CheckoutResult>(null),
          child: Text(l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: tendered >= 0
              ? () {
                  Navigator.of(context).pop(
                    CheckoutResult(method: _method, tendered: tendered, reference: _refCtrl.text.trim().isEmpty ? null : _refCtrl.text.trim()),
                  );
                }
              : null,
          icon: const Icon(Icons.check),
          label: Text(l10n.checkoutCompleteSale),
        )
      ],
    );
  }
}
