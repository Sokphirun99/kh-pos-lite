import 'package:flutter_test/flutter_test.dart';
import 'package:cashier_app/features/sales/bloc/cart_cubit.dart';
import 'package:cashier_app/features/sales/bloc/cart_state.dart';
import 'package:cashier_app/domain/entities/product.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';

void main() {
  group('CartCubit', () {
    test('add/increment/decrement and totals', () {
      final c = CartCubit();
      final p = Product(id: '1', name: 'A', sku: 'S', unitCost: const MoneyRiel(500), price: const MoneyRiel(1000), stock: 10);
      c.addProduct(p);
      expect(c.state.items.single.quantity, 1);
      expect(c.state.subtotal, 1000);
      c.increment('1');
      expect(c.state.items.single.quantity, 2);
      expect(c.state.subtotal, 2000);
      c.decrement('1');
      expect(c.state.items.single.quantity, 1);
      c.decrement('1');
      expect(c.state.items.isEmpty, true);
    });

    test('discount percent and amount', () {
      final c = CartCubit();
      final p = Product(id: '1', name: 'A', sku: 'S', unitCost: const MoneyRiel(0), price: const MoneyRiel(1000), stock: 10);
      c.addProduct(p, qty: 3); // subtotal 3000
      c.setDiscountMode(DiscountMode.percent);
      c.setDiscountValue(10);
      expect(c.state.discountAmount, 300);
      expect(c.state.total, 2700);
      c.setDiscountMode(DiscountMode.amount);
      c.setDiscountValue(500);
      expect(c.state.discountAmount, 500);
      expect(c.state.total, 2500);
    });
  });
}

