import 'package:equatable/equatable.dart';
import 'package:cashier_app/domain/entities/product.dart';
import 'cart_state.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartCleared extends CartEvent {
  const CartCleared();
}

class CartItemAdded extends CartEvent {
  final Product product;
  final int qty;
  const CartItemAdded(this.product, {this.qty = 1});
  @override
  List<Object?> get props => [product, qty];
}

class CartItemRemoved extends CartEvent {
  final String productId;
  const CartItemRemoved(this.productId);
  @override
  List<Object?> get props => [productId];
}

class CartQtySet extends CartEvent {
  final String productId;
  final int qty;
  const CartQtySet(this.productId, this.qty);
  @override
  List<Object?> get props => [productId, qty];
}

class CartIncremented extends CartEvent {
  final String productId;
  const CartIncremented(this.productId);
  @override
  List<Object?> get props => [productId];
}

class CartDecremented extends CartEvent {
  final String productId;
  const CartDecremented(this.productId);
  @override
  List<Object?> get props => [productId];
}

class CartDiscountModeSet extends CartEvent {
  final DiscountMode mode;
  const CartDiscountModeSet(this.mode);
  @override
  List<Object?> get props => [mode];
}

class CartDiscountValueSet extends CartEvent {
  final int value;
  const CartDiscountValueSet(this.value);
  @override
  List<Object?> get props => [value];
}

