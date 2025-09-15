import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier_app/domain/entities/product.dart';
import 'package:cashier_app/domain/repositories/product_repository.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductRepository repo;
  StreamSubscription<List<Product>>? _sub;

  ProductsBloc(this.repo) : super(const ProductsState.loading()) {
    on<ProductsSubscribed>(_onSubscribed);
    on<ProductAdded>(_onAdded);
    on<ProductUpdated>(_onUpdated);
    on<ProductDeleted>(_onDeleted);
  }

  Future<void> _onSubscribed(ProductsSubscribed event, Emitter<ProductsState> emit) async {
    await _sub?.cancel();
    emit(const ProductsState.loading());
    _sub = repo.watchAll().listen((items) {
      add(_ProductsEmit(items));
    });
  }

  Future<void> _onAdded(ProductAdded event, Emitter<ProductsState> emit) async {
    await repo.add(event.product);
  }

  Future<void> _onUpdated(ProductUpdated event, Emitter<ProductsState> emit) async {
    await repo.update(event.product);
  }

  Future<void> _onDeleted(ProductDeleted event, Emitter<ProductsState> emit) async {
    await repo.delete(event.id);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
