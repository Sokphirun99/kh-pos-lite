import 'package:flutter/material.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'dart:io';
import 'package:cashier_app/services/key_value_service.dart';

enum PaymentMethod { cash, transfer }

class CheckoutResult {
  final PaymentMethod method;
  final int tendered;
  final String? reference; // optional transfer reference
  const CheckoutResult({
    required this.method,
    required this.tendered,
    this.reference,
  });
}

class CheckoutScreen extends StatefulWidget {
  final int total; // in riel
  const CheckoutScreen({super.key, required this.total});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();

  static Future<CheckoutResult?> show(BuildContext context, int total) {
    return showModalBottomSheet<CheckoutResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CheckoutScreen(total: total),
    );
  }
}

class _CheckoutScreenState extends State<CheckoutScreen> {
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
    final theme = Theme.of(context);
    final khqrPath = KeyValueService.get<String>('khqr_image_path');
    final total = widget.total;
    final tendered = _tendered < 0 ? 0 : _tendered;
    final diff = tendered - total;
    final isEnough = tendered >= total;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // App bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
                Expanded(
                  child: Text(
                    l10n.checkoutTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance the close button
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.checkoutTotal,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '៛$total',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Payment Method Selection
                  Text(
                    'Payment Method',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<PaymentMethod>(
                    segments: [
                      ButtonSegment(
                        value: PaymentMethod.cash,
                        label: Text(l10n.checkoutCash),
                        icon: const Icon(Icons.payments),
                      ),
                      ButtonSegment(
                        value: PaymentMethod.transfer,
                        label: Text(l10n.checkoutTransfer),
                        icon: const Icon(Icons.account_balance),
                      ),
                    ],
                    selected: {_method},
                    onSelectionChanged: (s) =>
                        setState(() => _method = s.first),
                  ),

                  const SizedBox(height: 24),

                  // KHQR Code for transfer
                  if (_method == PaymentMethod.transfer &&
                      khqrPath != null) ...[
                    Text(
                      l10n.checkoutScanKhqr,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(khqrPath),
                            height: 200,
                            width: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Amount Received Input
                  Text(
                    l10n.checkoutAmountReceived,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tenderedCtrl,
                    keyboardType: TextInputType.number,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      prefixText: '៛ ',
                      prefixStyle: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  // Transfer Reference (if transfer)
                  if (_method == PaymentMethod.transfer) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.checkoutTxReference,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _refCtrl,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        hintText: 'Transaction reference (optional)',
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Change calculation (for cash)
                  if (_method == PaymentMethod.cash && isEnough) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Change',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '៛$diff',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Insufficient payment warning
                  if (!isEnough) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Insufficient payment amount',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),

          // Bottom actions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: !isEnough
                          ? null
                          : () {
                              final result = CheckoutResult(
                                method: _method,
                                tendered: tendered,
                                reference: _refCtrl.text.trim().isEmpty
                                    ? null
                                    : _refCtrl.text.trim(),
                              );
                              Navigator.of(context).pop(result);
                            },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Complete Payment',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Keep the old dialog for backward compatibility
class CheckoutDialog extends StatefulWidget {
  final int total;
  const CheckoutDialog({super.key, required this.total});

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  @override
  Widget build(BuildContext context) {
    // Redirect to the new full-screen checkout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
      CheckoutScreen.show(context, widget.total).then((result) {
        if (result != null) {
          Navigator.of(context).pop(result);
        }
      });
    });

    return const SizedBox.shrink();
  }
}
