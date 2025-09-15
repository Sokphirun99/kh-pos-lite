part of 'products_bloc.dart';

class ProductsState extends Equatable {
  final bool isLoading;
  final List<Product> items;
  final String? error;

  const ProductsState({required this.isLoading, required this.items, this.error});

  const ProductsState.loading() : this(isLoading: true, items: const []);
  const ProductsState.data(List<Product> items) : this(isLoading: false, items: items);
  const ProductsState.error(String message) : this(isLoading: false, items: const [], error: message);

  @override
  List<Object?> get props => [isLoading, items, error];
}

