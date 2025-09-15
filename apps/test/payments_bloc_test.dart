import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
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

    tearDown(() async {
      await ctrl.close();
    });

    blocTest<PaymentsBloc, PaymentsState>(
      'emits loading then data on subscription',
      build: () => PaymentsBloc(repo),
      act: (b) {
        b.add(const PaymentsSubscribed());
        ctrl.add([Payment(id: '1', saleId: 's', method: 'cash', amount: const MoneyRiel(500))]);
      },
      expect: () => [
        const PaymentsState.loading(),
        isA<PaymentsState>().having((s) => s.items.length, 'items', 1),
      ],
    );
  });
}

