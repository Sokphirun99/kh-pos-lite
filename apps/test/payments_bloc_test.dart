
import 'dart:async';
// Using plain flutter_test without bloc_test to avoid version conflicts
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cashier_app/features/payments/bloc/payments_bloc.dart';
import 'package:cashier_app/domain/repositories/payment_repository.dart';
import 'package:cashier_app/domain/entities/payment.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';

class _MockPaymentsRepo extends Mock implements PaymentRepository {}

void main() {
  group('PaymentsBloc', () {
    late _MockPaymentsRepo repo;
    late StreamController<List<Payment>> ctrl;

    setUp(() {
      repo = _MockPaymentsRepo();
      ctrl = StreamController<List<Payment>>.broadcast();
      when(() => repo.watchAll()).thenAnswer((_) => ctrl.stream);
      when(() => repo.add(any())).thenAnswer((_) async {});
      when(() => repo.update(any())).thenAnswer((_) async {});
      when(() => repo.delete(any())).thenAnswer((_) async {});
    });

    setUpAll(() {
      registerFallbackValue(Payment(
        id: 'fallback',
        saleId: 's',
        method: 'cash',
        amount: const MoneyRiel(0),
      ));
    });

    tearDown(() async {
      await ctrl.close();
    });

    test('emits loading then data on subscription', () async {
      final bloc = PaymentsBloc(repo);
      final states = <PaymentsState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PaymentsSubscribed());
      await testerRun();
      ctrl.add([Payment(id: '1', saleId: 's', method: 'cash', amount: const MoneyRiel(500))]);
      await testerRun();

      expect(states.first, const PaymentsState.loading());
      expect(states.any((s) => s.items.length == 1), isTrue);

      await sub.cancel();
      await bloc.close();
    });
  });
}

Future<void> testerRun() async {
  await Future<void>.delayed(const Duration(milliseconds: 10));
}
