import 'package:equatable/equatable.dart';
import 'package:cashier_app/domain/entities/product.dart';

enum DiscountMode { percent, amount }

class CartLine extends Equatable {
  final Product product;
  final int quantity;
  const CartLine({required this.product, required this.quantity});

  CartLine copyWith({Product? product, int? quantity}) => CartLine(
    product: product ?? this.product,
    quantity: quantity ?? this.quantity,
  );

  int get lineTotal => product.price.amount * quantity;

  @override
  List<Object?> get props => [product, quantity];
}

class CartState extends Equatable {
  final List<CartLine> items;
  final DiscountMode discountMode;
  final int discountValue; // percent (0-100) or amount in riel

  const CartState({
    required this.items,
    required this.discountMode,
    required this.discountValue,
  });

  const CartState.initial()
    : this(
        items: const [],
        discountMode: DiscountMode.percent,
        discountValue: 0,
      );

  int get subtotal => items.fold(0, (sum, it) => sum + it.lineTotal);
  int get discountAmount {
    if (discountMode == DiscountMode.percent) {
      final pct = discountValue.clamp(0, 100);
      return (subtotal * pct / 100).floor();
    }
    return discountValue.clamp(0, subtotal);
  }

  int get total => (subtotal - discountAmount).clamp(0, 1 << 31);

  CartState copyWith({
    List<CartLine>? items,
    DiscountMode? discountMode,
    int? discountValue,
  }) => CartState(
    items: items ?? this.items,
    discountMode: discountMode ?? this.discountMode,
    discountValue: discountValue ?? this.discountValue,
  );

  @override
  List<Object?> get props => [items, discountMode, discountValue];
}
