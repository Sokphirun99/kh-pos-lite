import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cashier_app/domain/entities/sale.dart';
import 'package:cashier_app/domain/entities/payment.dart';
import 'package:intl/intl.dart';
import 'package:cashier_app/core/utils/format_riel.dart';
import 'package:cashier_app/services/key_value_service.dart';

class ReceiptService {
  /// Builds a simple A4-ish narrow PDF receipt (80mm page width ~ 226pt; 58mm ~ 165pt)
  /// We use 58mm width by default for compact receipts.
  static Future<Uint8List> buildPdf({
    required Sale sale,
    required List<Payment> payments,
    int pageWidth = 165, // ~58mm
  }) async {
    final doc = pw.Document();

    pw.Font? khFont;
    try {
      final customPath = KeyValueService.get<String>('khmer_font_ttf_path');
      if (customPath != null && File(customPath).existsSync()) {
        khFont = pw.Font.ttf(File(customPath).readAsBytesSync().buffer.asByteData());
      }
    } catch (_) {
      // ignore font loading errors; fallback to default
    }

    final theme = pw.ThemeData.withFont(
      base: khFont ?? pw.Font.helvetica(),
      bold: khFont ?? pw.Font.helveticaBold(),
    );

    final shop = _loadShopProfile();
    final paid = payments.fold<int>(0, (s, p) => s + p.amount.amount);
    final remaining = (sale.total.amount - paid).clamp(0, 1 << 31);
    final df = DateFormat('yyyy-MM-dd HH:mm');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pageWidth.toDouble(), double.infinity, marginAll: 8),
        build: (ctx) => pw.Theme(
          data: theme,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              if (shop.name != null && shop.name!.isNotEmpty)
                pw.Text(shop.name!, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
              if ((shop.address ?? '').isNotEmpty)
                pw.Text(shop.address!, style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center),
              if ((shop.phone ?? '').isNotEmpty)
                pw.Text(shop.phone!, style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center),
              if ((shop.name ?? '').isEmpty)
                pw.Text('Receipt', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 6),
              pw.Text('Sale: ${sale.id}', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Date: ${df.format(sale.createdAt.toLocal())}', style: const pw.TextStyle(fontSize: 9)),
              pw.Divider(),
              _kv('Total', formatRiel(sale.total.amount)),
              _kv('Paid', formatRiel(paid)),
              _kv('Balance', formatRiel(remaining)),
              pw.SizedBox(height: 8),
              pw.Text('Payments', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              ...payments.map((p) => pw.Column(children: [
                    _kv(p.method, formatRiel(p.amount.amount)),
                    pw.SizedBox(height: 2),
                  ])),
              pw.SizedBox(height: 8),
              pw.Text(shop.footer?.isNotEmpty == true ? shop.footer! : 'Thank you!', textAlign: pw.TextAlign.center),
            ],
          ),
        ),
      ),
    );

    return doc.save();
  }

  static pw.Widget _kv(String k, String v) {
    return pw.Row(
      children: [
        pw.Expanded(child: pw.Text(k, style: const pw.TextStyle(fontSize: 10))),
        pw.Text(v, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  /// Build minimal ESC/POS bytes for a 58mm thermal printer.
  /// Note: Khmer rendering depends on printer firmware; often unsupported.
  static List<int> buildEscPos({
    required Sale sale,
    required List<Payment> payments,
  }) {
    final bytes = <int>[];
    final shop = _loadShopProfile();

    void writeText(String text, {bool center = false}) {
      // ESC @ init
      // Alignment: ESC a n (0 left, 1 center, 2 right)
      bytes.addAll([0x1B, 0x40]);
      bytes.addAll([0x1B, 0x61, center ? 1 : 0]);
      final data = ('$text\n').codeUnits;
      bytes.addAll(data);
    }

    final paid = payments.fold<int>(0, (s, p) => s + p.amount.amount);
    final remaining = (sale.total.amount - paid).clamp(0, 1 << 31);
    final df = DateFormat('yyyy-MM-dd HH:mm');

    if ((shop.name ?? '').isNotEmpty) writeText(shop.name!, center: true);
    if ((shop.address ?? '').isNotEmpty) writeText(shop.address!, center: true);
    if ((shop.phone ?? '').isNotEmpty) writeText(shop.phone!, center: true);
    if ((shop.name ?? '').isEmpty) writeText('Receipt', center: true);
    writeText('Sale: ${sale.id}');
    writeText('Date: ${df.format(sale.createdAt.toLocal())}');
    writeText('------------------------------');
    writeText('Total   : ${formatRiel(sale.total.amount)}');
    writeText('Paid    : ${formatRiel(paid)}');
    writeText('Balance : ${formatRiel(remaining)}');
    writeText('');
    writeText('Payments:');
    for (final p in payments) {
      writeText('- ${p.method}: ${formatRiel(p.amount.amount)}');
    }
    writeText('');
    writeText((shop.footer?.isNotEmpty == true) ? shop.footer! : 'Thank you!', center: true);

    // Feed and cut (if supported)
    bytes.addAll([0x1B, 0x64, 0x03]); // print and feed 3 lines
    bytes.addAll([0x1D, 0x56, 0x01]); // partial cut
    return bytes;
  }

  static _ShopProfile _loadShopProfile() {
    return _ShopProfile(
      name: KeyValueService.get<String>('shop_name'),
      address: KeyValueService.get<String>('shop_address'),
      phone: KeyValueService.get<String>('shop_phone'),
      footer: KeyValueService.get<String>('shop_footer'),
    );
  }
}

class _ShopProfile {
  final String? name;
  final String? address;
  final String? phone;
  final String? footer;
  _ShopProfile({this.name, this.address, this.phone, this.footer});
}
