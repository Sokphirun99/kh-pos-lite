part of 'sales_bloc.dart';

class SalesState extends Equatable {
  final bool isLoading;
  final List<Sale> items;
  final String? error;
  const SalesState({required this.isLoading, required this.items, this.error});

  const SalesState.loading() : this(isLoading: true, items: const []);
  const SalesState.data(List<Sale> items) : this(isLoading: false, items: items);
  const SalesState.error(String message) : this(isLoading: false, items: const [], error: message);

  @override
  List<Object?> get props => [isLoading, items, error];
}
