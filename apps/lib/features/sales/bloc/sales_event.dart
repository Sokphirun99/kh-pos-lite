part of 'sales_bloc.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();
  @override
  List<Object?> get props => [];
}

class SalesSubscribed extends SalesEvent {
  const SalesSubscribed();
}

class SaleAdded extends SalesEvent {
  final Sale sale;
  const SaleAdded(this.sale);
  @override
  List<Object?> get props => [sale];
}

class SaleUpdated extends SalesEvent {
  final Sale sale;
  const SaleUpdated(this.sale);
  @override
  List<Object?> get props => [sale];
}

class _SalesEmit extends SalesEvent {
  final List<Sale> items;
  const _SalesEmit(this.items);
  @override
  List<Object?> get props => [items];
}

class SaleDeleted extends SalesEvent {
  final String id;
  const SaleDeleted(this.id);
  @override
  List<Object?> get props => [id];
}
