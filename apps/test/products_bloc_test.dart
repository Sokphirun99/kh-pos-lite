import 'dart:async';
// Using plain flutter_test without bloc_test to avoid version conflicts
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cashier_app/features/products/bloc/products_bloc.dart';
import 'package:cashier_app/domain/repositories/product_repository.dart';
import 'package:cashier_app/domain/entities/product.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';

class _MockProductsRepo extends Mock implements ProductRepository {}

void main() {
  group('ProductsBloc', () {
    late _MockProductsRepo repo;
    late StreamController<List<Product>> ctrl;

    setUp(() {
      repo = _MockProductsRepo();
      ctrl = StreamController<List<Product>>.broadcast();
      when(() => repo.watchAll()).thenAnswer((_) => ctrl.stream);
      when(() => repo.add(any())).thenAnswer((_) async {});
      when(() => repo.update(any())).thenAnswer((_) async {});
      when(() => repo.delete(any())).thenAnswer((_) async {});
    });

    setUpAll(() {
      registerFallbackValue(
        Product(
          id: 'fallback',
          name: 'F',
          sku: 'FALL',
          unitCost: const MoneyRiel(0),
          price: const MoneyRiel(0),
          stock: 0,
        ),
      );
    });

    tearDown(() async {
      await ctrl.close();
    });

    test('emits loading then data on subscription', () async {
      final bloc = ProductsBloc(repo);
      final states = <ProductsState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const ProductsSubscribed());
      // allow initial loading to emit
      await testerRun();

      ctrl.add([
        Product(
          id: '1',
          name: 'A',
          sku: 'SKU-1',
          unitCost: const MoneyRiel(800),
          price: const MoneyRiel(1000),
          stock: 10,
        ),
      ]);
      await testerRun();

      expect(states.first, const ProductsState.loading());
      expect(states.any((s) => s.items.length == 1), isTrue);

      await sub.cancel();
      await bloc.close();
    });

    test('delegates add to repository', () async {
      final bloc = ProductsBloc(repo);
      final p = Product(
        id: 'a',
        name: 'N',
        sku: 'S-A',
        unitCost: const MoneyRiel(100),
        price: const MoneyRiel(150),
        stock: 1,
      );
      bloc.add(ProductAdded(p));
      await testerRun();
      verify(
        () => repo.add(any(that: predicate<Product>((p) => p.sku == 'S-A'))),
      ).called(1);
      await bloc.close();
    });

    test('delegates update to repository', () async {
      final bloc = ProductsBloc(repo);
      final p = Product(
        id: 'b',
        name: 'B',
        sku: 'S-B',
        unitCost: const MoneyRiel(200),
        price: const MoneyRiel(250),
        stock: 2,
      );
      bloc.add(ProductUpdated(p));
      await testerRun();
      verify(
        () => repo.update(any(that: predicate<Product>((p) => p.id == 'b'))),
      ).called(1);
      await bloc.close();
    });
  });
}

Future<void> testerRun() async {
  // allow microtask/event loop to progress
  await Future<void>.delayed(const Duration(milliseconds: 10));
}
