import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
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

    tearDown(() async {
      await ctrl.close();
    });

    blocTest<SalesBloc, SalesState>(
      'emits loading then data on subscription',
      build: () => SalesBloc(repo),
      act: (b) {
        b.add(const SalesSubscribed());
        ctrl.add([Sale(id: '1', createdAt: DateTime(2024), total: const MoneyRiel(1000))]);
      },
      expect: () => [
        const SalesState.loading(),
        isA<SalesState>().having((s) => s.items.length, 'items', 1),
      ],
    );
  });
}

