import 'package:cashier_app/domain/entities/product.dart';
import 'package:cashier_app/domain/repositories/product_repository.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';
import 'package:cashier_app/features/products/presentation/product_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductRepo extends Mock implements ProductRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProductFormPage validation', () {
    late _MockProductRepo repo;

    setUp(() {
      repo = _MockProductRepo();
      when(() => repo.getBySku(any())).thenAnswer((_) async => null);
    });

    Widget wrap(Widget child) {
      return RepositoryProvider<ProductRepository>.value(
        value: repo,
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    testWidgets('shows Required errors when fields empty', (tester) async {
      await tester.pumpWidget(wrap(const ProductFormPage()));

      // Tap Save without filling anything
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('blocks save on duplicate SKU', (tester) async {
      // Mock repo to return an existing product for given SKU
      when(() => repo.getBySku('DUP-SKU')).thenAnswer(
        (_) async => Product(
          id: 'x',
          name: 'Existing',
          sku: 'DUP-SKU',
          unitCost: const MoneyRiel(100),
          price: const MoneyRiel(200),
          stock: 5,
        ),
      );

      await tester.pumpWidget(wrap(const ProductFormPage()));

      await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'New');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'SKU'),
        'DUP-SKU',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Unit cost (៛)'),
        '100',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Price (៛)'),
        '200',
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Stock'), '1');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();

      // Expect a snackbar about duplicate SKU and form not popped
      expect(find.text('SKU already exists'), findsOneWidget);
      expect(find.byType(ProductFormPage), findsOneWidget);
    });
  });
}
