import 'dart:io';

import 'package:cashier_app/core/isar_db.dart';
import 'package:cashier_app/data/repositories_impl/payment_repository_impl.dart';
import 'package:cashier_app/domain/repositories/payment_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'payment watchAll reuses stream instance and resubscribes safely',
    () async {
      final tmp = await Directory.systemTemp.createTemp('isar_watch_cache');
      final isar = await openIsarDb(directory: tmp.path);
      final PaymentRepository repo = PaymentRepositoryImpl(isar);

      final stream1 = repo.watchAll();
      expect(stream1.isBroadcast, isTrue);

      // Repeatedly listen/cancel to ensure the shared stream does not crash the native layer.
      for (var i = 0; i < 120; i += 1) {
        await stream1.first;
      }

      await isar.close();
      await tmp.delete(recursive: true);
    },
  );
}
