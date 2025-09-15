import 'package:isar/isar.dart';
import 'package:cashier_app/data/local/isar_collections.dart';

const int kCurrentDbVersion = 2;
const String _dbVersionKey = 'dbVersion';

Future<void> runMigrations(Isar isar) async {
  // read current stored version
  final kv = await isar.metaKVs.filter().keyEqualTo(_dbVersionKey).findFirst();
  final current = int.tryParse(kv?.value ?? '0') ?? 0;
  int v = current;
  while (v < kCurrentDbVersion) {
    v += 1;
    switch (v) {
      case 1:
        // Initial migration placeholder (no-op)
        break;
      case 2:
        // v2: Backfill or normalize fields
        // - Ensure updatedAt is set on all records
        // - Example normalization: lowercase payment.method
        await isar.writeTxn(() async {
          // Products
          final products = await isar.productModels.where().findAll();
          for (final p in products) {
            if (p.updatedAt.isBefore(DateTime(1971))) {
              p.updatedAt = DateTime.now().toUtc();
              await isar.productModels.put(p);
            }
          }

          // Sales: set updatedAt to createdAt if not initialized
          final sales = await isar.saleModels.where().findAll();
          for (final s in sales) {
            if (s.updatedAt.isBefore(DateTime(1971))) {
              s.updatedAt = s.createdAt;
              await isar.saleModels.put(s);
            }
          }

          // Payments: lowercase method + ensure updatedAt
          final payments = await isar.paymentModels.where().findAll();
          for (final pmt in payments) {
            final newMethod = pmt.method.toLowerCase();
            var changed = false;
            if (pmt.method != newMethod) {
              pmt.method = newMethod;
              changed = true;
            }
            if (pmt.updatedAt.isBefore(DateTime(1971))) {
              pmt.updatedAt = DateTime.now().toUtc();
              changed = true;
            }
            if (changed) {
              await isar.paymentModels.put(pmt);
            }
          }
        });
        break;
      default:
        break;
    }
  }
  if (v != current) {
    await isar.writeTxn(() async {
      final rec = MetaKV()
        ..key = _dbVersionKey
        ..value = v.toString();
      await isar.metaKVs.putByKey(rec);
    });
  }
}
