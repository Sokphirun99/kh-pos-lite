import 'dart:convert';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:cashier_app/domain/entities/product.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';
import 'package:cashier_app/services/key_value_service.dart';
import 'cart_state.dart';
import 'cart_event.dart';

class CartBloc extends HydratedBloc<CartEvent, CartState> {
  CartBloc() : super(const CartState.initial()) {
    on<CartCleared>((e, emit) => emit(const CartState.initial()));
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartQtySet>(_onQtySet);
    on<CartIncremented>((e, emit) {
      final it = state.items.firstWhere((x) => x.product.id == e.productId, orElse: () => CartLine(product: _dummy, quantity: 0));
      if (it.product.id == _dummy.id) return;
      add(CartQtySet(e.productId, it.quantity + 1));
    });
    on<CartDecremented>((e, emit) {
      final it = state.items.firstWhere((x) => x.product.id == e.productId, orElse: () => CartLine(product: _dummy, quantity: 0));
      if (it.product.id == _dummy.id) return;
      add(CartQtySet(e.productId, it.quantity - 1));
    });
    on<CartDiscountModeSet>((e, emit) => emit(state.copyWith(discountMode: e.mode)));
    on<CartDiscountValueSet>((e, emit) {
      var v = e.value;
      if (state.discountMode == DiscountMode.percent) v = v.clamp(0, 100);
      emit(state.copyWith(discountValue: v));
    });
  }

  static final _dummy = Product(id: '__none__', name: '', sku: '', unitCost: const MoneyRiel(0), price: const MoneyRiel(0), stock: 0);

  void _onItemAdded(CartItemAdded e, Emitter<CartState> emit) {
    final allowOversell = (KeyValueService.get<bool>('allow_oversell') ?? false);
    final items = List<CartLine>.from(state.items);
    final idx = items.indexWhere((x) => x.product.id == e.product.id);
    if (idx >= 0) {
      final curr = items[idx];
      final desired = curr.quantity + e.qty;
      final nextQty = allowOversell ? desired : (desired > curr.product.stock ? curr.product.stock : desired);
      items[idx] = curr.copyWith(quantity: nextQty);
    } else {
      final initial = allowOversell ? e.qty : (e.qty > e.product.stock ? e.product.stock : e.qty);
      if (initial > 0) items.add(CartLine(product: e.product, quantity: initial));
    }
    emit(state.copyWith(items: items));
  }

  void _onItemRemoved(CartItemRemoved e, Emitter<CartState> emit) {
    emit(state.copyWith(items: state.items.where((x) => x.product.id != e.productId).toList()));
  }

  void _onQtySet(CartQtySet e, Emitter<CartState> emit) {
    if (e.qty <= 0) {
      _onItemRemoved(CartItemRemoved(e.productId), emit);
      return;
    }
    final allowOversell = (KeyValueService.get<bool>('allow_oversell') ?? false);
    final items = state.items
        .map((x) {
          if (x.product.id == e.productId) {
            final nextQty = allowOversell ? e.qty : (e.qty > x.product.stock ? x.product.stock : e.qty);
            return x.copyWith(quantity: nextQty);
          }
          return x;
        })
        .toList(growable: false);
    emit(state.copyWith(items: items));
  }

  @override
  CartState? fromJson(Map<String, dynamic> json) {
    try {
      final items = (json['items'] as List<dynamic>? ?? const [])
          .map((e) => _lineFromJson(e as Map<String, dynamic>))
          .whereType<CartLine>()
          .toList();
      final modeStr = json['discountMode'] as String? ?? 'percent';
      final mode = modeStr == 'amount' ? DiscountMode.amount : DiscountMode.percent;
      final value = (json['discountValue'] as int?) ?? 0;
      return CartState(items: items, discountMode: mode, discountValue: value);
    } catch (_) {
      return const CartState.initial();
    }
  }

  @override
  Map<String, dynamic>? toJson(CartState state) {
    return {
      'items': state.items.map(_lineToJson).toList(),
      'discountMode': state.discountMode == DiscountMode.amount ? 'amount' : 'percent',
      'discountValue': state.discountValue,
    };
  }

  static Map<String, dynamic> _productToJson(Product p) => {
        'id': p.id,
        'name': p.name,
        'sku': p.sku,
        'unitCost': p.unitCost.amount,
        'price': p.price.amount,
        'stock': p.stock,
      };

  static Product _productFromJson(Map<String, dynamic> m) => Product(
        id: m['id'] as String,
        name: m['name'] as String,
        sku: m['sku'] as String,
        unitCost: MoneyRiel((m['unitCost'] as num).toInt()),
        price: MoneyRiel((m['price'] as num).toInt()),
        stock: (m['stock'] as num).toInt(),
      );

  static Map<String, dynamic> _lineToJson(CartLine l) => {
        'product': _productToJson(l.product),
        'quantity': l.quantity,
      };

  static CartLine? _lineFromJson(Map<String, dynamic> m) {
    try {
      final p = _productFromJson(Map<String, dynamic>.from(m['product'] as Map));
      final q = (m['quantity'] as num).toInt();
      return CartLine(product: p, quantity: q);
    } catch (_) {
      return null;
    }
  }
}

