part of 'products_bloc.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();
  @override
  List<Object?> get props => [];
}

class ProductsSubscribed extends ProductsEvent {
  const ProductsSubscribed();
}

class ProductAdded extends ProductsEvent {
  final Product product;
  const ProductAdded(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductUpdated extends ProductsEvent {
  final Product product;
  const ProductUpdated(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductDeleted extends ProductsEvent {
  final String id;
  const ProductDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class _ProductsEmit extends ProductsEvent {
  final List<Product> items;
  const _ProductsEmit(this.items);
  @override
  List<Object?> get props => [items];
}
