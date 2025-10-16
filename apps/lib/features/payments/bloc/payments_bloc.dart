import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier_app/domain/entities/payment.dart';
import 'package:cashier_app/domain/repositories/payment_repository.dart';

part 'payments_event.dart';
part 'payments_state.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final PaymentRepository repo;
  StreamSubscription<List<Payment>>? _sub;

  PaymentsBloc(this.repo) : super(const PaymentsState.loading()) {
    on<PaymentsSubscribed>(_onSubscribed);
    on<PaymentAdded>(_onAdded);
    on<PaymentUpdated>(_onUpdated);
    on<PaymentDeleted>(_onDeleted);
    on<_PaymentsEmit>((event, emit) => emit(PaymentsState.data(event.items)));
  }

  Future<void> _onSubscribed(
    PaymentsSubscribed event,
    Emitter<PaymentsState> emit,
  ) async {
    await _sub?.cancel();
    emit(const PaymentsState.loading());
    _sub = repo.watchAll().listen((items) => add(_PaymentsEmit(items)));
  }

  Future<void> _onAdded(PaymentAdded event, Emitter<PaymentsState> emit) async {
    await repo.add(event.payment);
  }

  Future<void> _onUpdated(
    PaymentUpdated event,
    Emitter<PaymentsState> emit,
  ) async {
    await repo.update(event.payment);
  }

  Future<void> _onDeleted(
    PaymentDeleted event,
    Emitter<PaymentsState> emit,
  ) async {
    await repo.delete(event.id);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
