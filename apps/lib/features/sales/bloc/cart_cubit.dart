import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier_app/domain/entities/product.dart';
import 'cart_state.dart';
import 'package:cashier_app/services/key_value_service.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState.initial());

  void clear() => emit(const CartState.initial());

  void addProduct(Product p, {int qty = 1}) {
    final allowOversell =
        (KeyValueService.get<bool>('allow_oversell') ?? false);
    final items = List<CartLine>.from(state.items);
    final idx = items.indexWhere((e) => e.product.id == p.id);
    if (idx >= 0) {
      final curr = items[idx];
      final desired = curr.quantity + qty;
      final nextQty = allowOversell
          ? desired
          : (desired > p.stock ? p.stock : desired);
      items[idx] = curr.copyWith(quantity: nextQty);
    } else {
      final initial = allowOversell ? qty : (qty > p.stock ? p.stock : qty);
      if (initial > 0) items.add(CartLine(product: p, quantity: initial));
    }
    emit(state.copyWith(items: items));
  }

  void removeLine(String productId) {
    emit(
      state.copyWith(
        items: state.items.where((e) => e.product.id != productId).toList(),
      ),
    );
  }

  void setQuantity(String productId, int qty) {
    if (qty <= 0) {
      removeLine(productId);
      return;
    }
    final allowOversell =
        (KeyValueService.get<bool>('allow_oversell') ?? false);
    final items = state.items
        .map((e) {
          if (e.product.id == productId) {
            final nextQty = allowOversell
                ? qty
                : (qty > e.product.stock ? e.product.stock : qty);
            return e.copyWith(quantity: nextQty);
          }
          return e;
        })
        .toList(growable: false);
    emit(state.copyWith(items: items));
  }

  void increment(String productId) {
    final it = state.items.firstWhere(
      (e) => e.product.id == productId,
      orElse: () => throw StateError('Not found'),
    );
    setQuantity(productId, it.quantity + 1);
  }

  void decrement(String productId) {
    final it = state.items.firstWhere(
      (e) => e.product.id == productId,
      orElse: () => throw StateError('Not found'),
    );
    setQuantity(productId, it.quantity - 1);
  }

  void setDiscountMode(DiscountMode mode) {
    emit(state.copyWith(discountMode: mode));
  }

  void setDiscountValue(int value) {
    if (state.discountMode == DiscountMode.percent) {
      value = value.clamp(0, 100);
    } else {
      value = value.clamp(0, 1 << 31);
    }
    emit(state.copyWith(discountValue: value));
  }
}
