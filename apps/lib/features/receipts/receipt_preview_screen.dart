import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import 'package:cashier_app/domain/repositories/sale_repository.dart';
import 'package:cashier_app/domain/repositories/payment_repository.dart';
import 'package:cashier_app/domain/entities/sale.dart';
import 'package:cashier_app/domain/entities/payment.dart';
import 'package:cashier_app/features/receipts/receipt_service.dart';
import 'package:cashier_app/l10n/app_localizations.dart';

class ReceiptPreviewScreen extends StatelessWidget {
  final String saleId;
  const ReceiptPreviewScreen({super.key, required this.saleId});

  @override
  Widget build(BuildContext context) {
    final saleRepo = context.read<SaleRepository>();
    final payRepo = context.read<PaymentRepository>();
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).receipt)),
      body: FutureBuilder<Sale?>(
        future: saleRepo.getById(saleId),
        builder: (context, saleSnap) {
          final sale = saleSnap.data;
          if (sale == null) return const Center(child: CircularProgressIndicator());
          return StreamBuilder<List<Payment>>(
            stream: payRepo.watchAll(),
            builder: (context, paySnap) {
              final pays = (paySnap.data ?? const <Payment>[]).where((p) => p.saleId == sale.id).toList();
              return PdfPreview(
                build: (format) => ReceiptService.buildPdf(sale: sale, payments: pays, pageWidth: 165),
                canChangeOrientation: false,
                canChangePageFormat: false,
                pdfFileName: 'receipt_${sale.id}.pdf',
              );
            },
          );
        },
      ),
    );
  }
}

