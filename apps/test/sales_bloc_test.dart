import 'dart:async';
// Using plain flutter_test without bloc_test to avoid version conflicts
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cashier_app/features/sales/bloc/sales_bloc.dart';
import 'package:cashier_app/domain/repositories/sale_repository.dart';
import 'package:cashier_app/domain/entities/sale.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';

class _MockSalesRepo extends Mock implements SaleRepository {}

void main() {
  group('SalesBloc', () {
    late _MockSalesRepo repo;
    late StreamController<List<Sale>> ctrl;

    setUp(() {
      repo = _MockSalesRepo();
      ctrl = StreamController<List<Sale>>.broadcast();
      when(() => repo.watchAll()).thenAnswer((_) => ctrl.stream);
      when(() => repo.add(any())).thenAnswer((_) async {});
      when(() => repo.update(any())).thenAnswer((_) async {});
      when(() => repo.delete(any())).thenAnswer((_) async {});
    });

    setUpAll(() {
      registerFallbackValue(
        Sale(
          id: 'fallback',
          createdAt: DateTime(2024),
          total: const MoneyRiel(0),
        ),
      );
    });

    tearDown(() async {
      await ctrl.close();
    });

    test('emits loading then data on subscription', () async {
      final bloc = SalesBloc(repo);
      final states = <SalesState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const SalesSubscribed());
      await testerRun();
      ctrl.add([
        Sale(id: '1', createdAt: DateTime(2024), total: const MoneyRiel(1000)),
      ]);
      await testerRun();

      expect(states.first, const SalesState.loading());
      expect(states.any((s) => s.items.length == 1), isTrue);

      await sub.cancel();
      await bloc.close();
    });
  });
}

Future<void> testerRun() async {
  await Future<void>.delayed(const Duration(milliseconds: 10));
}
