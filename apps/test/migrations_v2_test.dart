import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashier_app/core/isar_db.dart';
import 'package:cashier_app/data/local/isar_collections.dart';
import 'package:isar/isar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('v2 migration normalizes updatedAt and payment.method', () async {
    final tmp = await Directory.systemTemp.createTemp('isar_mig');

    // Open DB and seed v1 state
    var isar = await openIsarDb(directory: tmp.path);
    await isar.writeTxn(() async {
      // Mark dbVersion as 1
      final rec = MetaKV()
        ..key = 'dbVersion'
        ..value = '1';
      await isar.metaKVs.putByKey(rec);

      // Seed product with epoch updatedAt
      final p = ProductModel()
        ..uid = 'p1'
        ..name = 'X'
        ..price = 1000
        ..sku = 'DUMMY-SKU'
        ..updatedAt = DateTime.fromMillisecondsSinceEpoch(0).toUtc();
      await isar.productModels.put(p);

      // Seed sale with epoch updatedAt
      final s = SaleModel()
        ..uid = 's1'
        ..createdAt = DateTime.utc(2024)
        ..total = 2000
        ..updatedAt = DateTime.fromMillisecondsSinceEpoch(0).toUtc();
      await isar.saleModels.put(s);

      // Seed payment with uppercase method and epoch updatedAt
      final pm = PaymentModel()
        ..uid = 'pm1'
        ..saleUid = 's1'
        ..method = 'CASH'
        ..amount = 500
        ..updatedAt = DateTime.fromMillisecondsSinceEpoch(0).toUtc();
      await isar.paymentModels.put(pm);
    });
    await isar.close();

    // Reopen, run migrations (v1 -> v2)
    isar = await openIsarDb(directory: tmp.path);

    final pLoaded = await isar.productModels.filter().uidEqualTo('p1').findFirst();
    final sLoaded = await isar.saleModels.filter().uidEqualTo('s1').findFirst();
    final pmLoaded = await isar.paymentModels.filter().uidEqualTo('pm1').findFirst();
    final ver = await isar.metaKVs.filter().keyEqualTo('dbVersion').findFirst();

    expect(ver?.value, '2');
    expect(pLoaded, isNotNull);
    expect(pLoaded!.updatedAt.isAfter(DateTime(1971)), true);
    expect(sLoaded, isNotNull);
    // sales updatedAt set to createdAt
    expect(sLoaded!.updatedAt, sLoaded.createdAt);
    expect(pmLoaded, isNotNull);
    expect(pmLoaded!.method, 'cash');
    expect(pmLoaded.updatedAt.isAfter(DateTime(1971)), true);

    await isar.close();
    await tmp.delete(recursive: true);
  });
}

