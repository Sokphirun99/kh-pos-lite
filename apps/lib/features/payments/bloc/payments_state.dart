part of 'payments_bloc.dart';

class PaymentsState extends Equatable {
  final bool isLoading;
  final List<Payment> items;
  final String? error;
  const PaymentsState({required this.isLoading, required this.items, this.error});

  const PaymentsState.loading() : this(isLoading: true, items: const []);
  const PaymentsState.data(List<Payment> items) : this(isLoading: false, items: items);
  const PaymentsState.error(String message) : this(isLoading: false, items: const [], error: message);

  @override
  List<Object?> get props => [isLoading, items, error];
}
