part of 'payments_bloc.dart';

abstract class PaymentsEvent extends Equatable {
  const PaymentsEvent();
  @override
  List<Object?> get props => [];
}

class PaymentsSubscribed extends PaymentsEvent {
  const PaymentsSubscribed();
}

class PaymentAdded extends PaymentsEvent {
  final Payment payment;
  const PaymentAdded(this.payment);
  @override
  List<Object?> get props => [payment];
}

class PaymentUpdated extends PaymentsEvent {
  final Payment payment;
  const PaymentUpdated(this.payment);
  @override
  List<Object?> get props => [payment];
}

class _PaymentsEmit extends PaymentsEvent {
  final List<Payment> items;
  const _PaymentsEmit(this.items);
  @override
  List<Object?> get props => [items];
}

class PaymentDeleted extends PaymentsEvent {
  final String id;
  const PaymentDeleted(this.id);
  @override
  List<Object?> get props => [id];
}
