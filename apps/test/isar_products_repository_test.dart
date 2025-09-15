import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashier_app/core/isar_db.dart';
import 'package:cashier_app/data/repositories_impl/product_repository_impl.dart';
import 'package:cashier_app/domain/repositories/product_repository.dart';
import 'package:cashier_app/domain/entities/product.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Isar repo watchAll emits after add', () async {
    final tmp = await Directory.systemTemp.createTemp('isar_test');
    final isar = await openIsarDb(directory: tmp.path);
    final ProductRepository repo = ProductRepositoryImpl(isar);

    final id = 'p1';

    // Start listening before adding
    final stream = repo.watchAll();
    final future = expectLater(
      stream,
      emitsThrough(predicate<List<Product>>((items) => items.any((p) => p.id == id))),
    );

    await repo.add(Product(
      id: id,
      name: 'Test',
      sku: 'DUMMY-SKU',
      unitCost: const MoneyRiel(800),
      price: const MoneyRiel(1000),
      stock: 3,
    ));
    await future;

    await isar.close();
    await tmp.delete(recursive: true);
  });
}
