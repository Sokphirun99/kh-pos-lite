import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier_app/domain/entities/sale.dart';
import 'package:cashier_app/domain/repositories/sale_repository.dart';

part 'sales_event.dart';
part 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final SaleRepository repo;
  StreamSubscription<List<Sale>>? _sub;

  SalesBloc(this.repo) : super(const SalesState.loading()) {
    on<SalesSubscribed>(_onSubscribed);
    on<SaleAdded>(_onAdded);
    on<SaleUpdated>(_onUpdated);
    on<SaleDeleted>(_onDeleted);
    on<_SalesEmit>((event, emit) => emit(SalesState.data(event.items)));
  }

  Future<void> _onSubscribed(SalesSubscribed event, Emitter<SalesState> emit) async {
    await _sub?.cancel();
    emit(const SalesState.loading());
    _sub = repo.watchAll().listen((items) => add(_SalesEmit(items)));
  }

  Future<void> _onAdded(SaleAdded event, Emitter<SalesState> emit) async {
    await repo.add(event.sale);
  }

  Future<void> _onUpdated(SaleUpdated event, Emitter<SalesState> emit) async {
    await repo.update(event.sale);
  }

  Future<void> _onDeleted(SaleDeleted event, Emitter<SalesState> emit) async {
    await repo.delete(event.id);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
