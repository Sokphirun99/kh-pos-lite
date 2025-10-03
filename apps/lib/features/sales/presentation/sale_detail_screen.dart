import 'package:cashier_app/domain/entities/payment.dart';
import 'package:cashier_app/domain/entities/sale.dart';
import 'package:cashier_app/domain/repositories/payment_repository.dart';
import 'package:cashier_app/domain/repositories/sale_repository.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';
import 'package:cashier_app/features/sales/presentation/checkout_dialog.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cashier_app/services/key_value_service.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cashier_app/features/receipts/receipt_service.dart';
import 'package:cashier_app/services/bluetooth_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:cashier_app/services/telegram_service.dart';

class SaleDetailScreen extends StatelessWidget {
  final String saleId;
  const SaleDetailScreen({super.key, required this.saleId});

  @override
  Widget build(BuildContext context) {
    final saleRepo = context.read<SaleRepository>();
    final payRepo = context.read<PaymentRepository>();
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<Sale?>(
      future: saleRepo.getById(saleId),
      builder: (context, saleSnap) {
        if (saleSnap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.saleDetailsTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final sale = saleSnap.data;
        if (sale == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.saleDetailsTitle)),
            body: Center(child: Text(l10n.saleNotFound)),
          );
        }
        return StreamBuilder<List<Payment>>(
          stream: payRepo.watchAll(),
          builder: (context, paySnap) {
            final allPays = paySnap.data ?? const <Payment>[];
            final pays = allPays.where((p) => p.saleId == sale.id).toList();
            final paid = pays.fold<int>(0, (sum, p) => sum + p.amount.amount);
            final remaining = (sale.total.amount - paid).clamp(0, 1 << 31);

            Future<void> receivePayment() async {
              final result = await showDialog<CheckoutResult>(
                context: context,
                builder: (_) => CheckoutDialog(total: remaining),
              );
              if (result == null) return;
              final payment = Payment(
                id: const Uuid().v4(),
                saleId: sale.id,
                method: result.method == PaymentMethod.cash ? 'cash' : 'transfer',
                amount: MoneyRiel(result.tendered),
              );
                                      await payRepo.add(payment);
                                      if (result.reference != null && result.reference!.isNotEmpty) {
                                        await KeyValueService.set('payment_ref_${payment.id}', result.reference!);
                                      }
                                      final change = result.tendered - remaining;
              final msg = change >= 0
                  ? (AppLocalizations.of(context).saleCompletedChange('៛$change'))
                  : (AppLocalizations.of(context).saleCompletedRemaining('៛${(-change)}'));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
              }
            }

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.saleDetailsTitle),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'print') {
                      final addr = KeyValueService.get<String>('bt_printer_addr');
                      if (addr == null || addr.isEmpty) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pairPrinter)));
                          context.pushNamed('printers');
                        }
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.printingStarted)));
                      try {
                        await BluetoothService().connectTo(addr);
                        final data = ReceiptService.buildEscPos(sale: sale, payments: pays);
                        await BluetoothService().sendBytes(data);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.printingDone)));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.printingFailed)));
                        }
                      }
                    } else if (v == 'pair') {
                      if (context.mounted) context.pushNamed('printers');
                    } else if (v == 'share') {
                      final pdf = await ReceiptService.buildPdf(sale: sale, payments: pays);
                      final dir = await getTemporaryDirectory();
                      final f = File('${dir.path}/receipt_${sale.id}.pdf');
                      await f.writeAsBytes(pdf, flush: true);
                      await Share.shareXFiles([XFile(f.path)], text: l10n.receipt);
                    } else if (v == 'preview') {
                      if (context.mounted) context.pushNamed('receipt_preview', pathParameters: {'id': sale.id});
                    } else if (v == 'tg') {
                      try {
                        final pdf = await ReceiptService.buildPdf(sale: sale, payments: pays);
                        final dir = await getTemporaryDirectory();
                        final f = File('${dir.path}/receipt_${sale.id}.pdf');
                        await f.writeAsBytes(pdf, flush: true);
                        await TelegramService().sendDocument(file: f, caption: l10n.receipt);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Telegram: OK')));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.telegramNotConfigured)));
                        }
                      }
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(value: 'pair', child: Text(l10n.pairPrinter)),
                    PopupMenuItem(value: 'print', child: Text(l10n.printBluetooth)),
                    PopupMenuItem(value: 'share', child: Text(l10n.sharePdf)),
                    const PopupMenuItem(value: 'preview', child: Text('Preview')),
                    PopupMenuItem(value: 'tg', child: Text(l10n.sendTelegram)),
                  ],
                )
              ],
            ),
            body: Column(
                children: [
                  _SaleHeader(sale: sale, paid: paid, remaining: remaining),
                  const Divider(height: 0),
                  Expanded(
                    child: pays.isEmpty
                        ? Center(child: Text(l10n.noPayments))
                        : ListView.separated(
                            itemCount: pays.length,
                            separatorBuilder: (_, __) => const Divider(height: 0),
                            itemBuilder: (_, i) {
                              final p = pays[i];
                              final ref = KeyValueService.get<String>('payment_ref_${p.id}');

                              Future<void> deletePayment() async {
                                final prevRef = ref;
                                await payRepo.delete(p.id);
                                if (prevRef != null && prevRef.isNotEmpty) {
                                  await KeyValueService.remove('payment_ref_${p.id}');
                                }
                                if (context.mounted) {
                                  final snack = SnackBar(
                                    content: Text(l10n.settingsSyncDeleted),
                                    action: SnackBarAction(
                                      label: l10n.undo,
                                      onPressed: () async {
                                        await payRepo.add(p);
                                        if (prevRef != null && prevRef.isNotEmpty) {
                                          await KeyValueService.set('payment_ref_${p.id}', prevRef);
                                        }
                                      },
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snack);
                                }
                              }

                              return Dismissible(
                                key: ValueKey(p.id),
                                background: Container(color: Colors.red),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) async => deletePayment(),
                                child: ListTile(
                                  leading: const Icon(Icons.payments),
                                  title: Text('៛${p.amount.amount}'),
                                  subtitle: Text(ref == null || ref.isEmpty ? p.method : '${p.method} • ${l10n.txRefLabel(ref)}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (ref != null && ref.isNotEmpty)
                                        IconButton(
                                          tooltip: l10n.aboutCopied,
                                          icon: const Icon(Icons.copy),
                                          onPressed: () async {
                                            await Clipboard.setData(ClipboardData(text: ref));
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(l10n.aboutCopied)),
                                              );
                                            }
                                          },
                                        ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: deletePayment,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: remaining <= 0 ? null : receivePayment,
                              child: Text(l10n.receivePayment),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: remaining <= 0 ? null : receivePayment,
                tooltip: l10n.receivePayment,
                child: const Icon(Icons.payments),
              ),
            );
          },
        );
      },
    );
  }
}

class _SaleHeader extends StatelessWidget {
  final Sale sale;
  final int paid;
  final int remaining;
  const _SaleHeader({required this.sale, required this.paid, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final dt = DateFormat.yMMMd().add_Hm().format(sale.createdAt.toLocal());
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sale ${sale.id}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(dt, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(AppLocalizations.of(context).checkoutTotal),
              const Spacer(),
              Text('៛${sale.total.amount}', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(AppLocalizations.of(context).paid),
              const Spacer(),
              Text('៛$paid'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(AppLocalizations.of(context).balance, style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              Text('៛$remaining', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ],
      ),
    );
  }
}
