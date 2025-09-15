import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
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

    tearDown(() async {
      await ctrl.close();
    });

    blocTest<ProductsBloc, ProductsState>(
      'emits loading then data on subscription',
      build: () => ProductsBloc(repo),
      act: (b) {
        b.add(const ProductsSubscribed());
        ctrl.add([Product(id: '1', name: 'A', price: const MoneyRiel(1000))]);
      },
      expect: () => [
        const ProductsState.loading(),
        isA<ProductsState>().having((s) => s.items.length, 'items', 1),
      ],
    );
  });
}

