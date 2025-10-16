import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'app/app.dart';
import 'app/bloc_observer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/repositories/sale_repository.dart';
import 'domain/repositories/payment_repository.dart';
import 'data/repositories_impl/product_repository_impl.dart';
import 'data/repositories_impl/sale_repository_impl.dart';
import 'data/repositories_impl/payment_repository_impl.dart';
import 'core/isar_db.dart';
import 'services/key_value_service.dart';
import 'core/env/config.dart';
import 'domain/entities/product.dart';
import 'domain/value_objects/money_riel.dart';

/// Main entry point for KH POS Lite - OFFLINE PRODUCTION VERSION
///
/// This version runs completely offline without any API dependencies.
/// All data is stored locally using Isar database.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize state persistence for BLoC
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  Bloc.observer = AppBlocObserver();

  // Initialize lightweight key-value storage for app settings
  await KeyValueService.init();

  // Initialize local database and create repository instances
  final isar = await openIsarDb();
  final ProductRepository productsRepo = ProductRepositoryImpl(isar);
  final SaleRepository salesRepo = SaleRepositoryImpl(isar);
  final PaymentRepository paymentsRepo = PaymentRepositoryImpl(isar);

  // Seed sample data if this is the first run
  await _seedSampleDataIfNeeded(productsRepo);

  // Set offline mode indicator
  await KeyValueService.set<bool>('offline_mode', true);
  await KeyValueService.set<String>('app_mode', 'OFFLINE PRODUCTION');

  // Start the application with dependency injection
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProductRepository>.value(value: productsRepo),
        RepositoryProvider<SaleRepository>.value(value: salesRepo),
        RepositoryProvider<PaymentRepository>.value(value: paymentsRepo),
      ],
      child: const App(),
    ),
  );
}

/// Seeds the database with sample products if no products exist
Future<void> _seedSampleDataIfNeeded(ProductRepository productRepo) async {
  try {
    final existingProducts = await productRepo.list();
    
    if (existingProducts.isEmpty) {
      print('🌱 Seeding sample data for offline demo...');
      
      final sampleProducts = [
        Product(
          id: 'coffee-001',
          name: 'Americano Coffee',
          sku: 'COFFEE-001',
          unitCost: const MoneyRiel(3000), // 3000 KHR cost
          price: const MoneyRiel(8000), // 8000 KHR selling price
          stock: 50,
        ),
        Product(
          id: 'coffee-002',
          name: 'Cappuccino',
          sku: 'COFFEE-002',
          unitCost: const MoneyRiel(4000),
          price: const MoneyRiel(10000),
          stock: 30,
        ),
        Product(
          id: 'tea-001',
          name: 'Iced Tea',
          sku: 'TEA-001',
          unitCost: const MoneyRiel(2000),
          price: const MoneyRiel(6000),
          stock: 40,
        ),
        Product(
          id: 'food-001',
          name: 'Chicken Sandwich',
          sku: 'FOOD-001',
          unitCost: const MoneyRiel(8000),
          price: const MoneyRiel(15000),
          stock: 25,
        ),
        Product(
          id: 'food-002',
          name: 'Croissant',
          sku: 'FOOD-002',
          unitCost: const MoneyRiel(3000),
          price: const MoneyRiel(8000),
          stock: 20,
        ),
        Product(
          id: 'snack-001',
          name: 'Chocolate Chip Cookies',
          sku: 'SNACK-001',
          unitCost: const MoneyRiel(2000),
          price: const MoneyRiel(6000),
          stock: 35,
        ),
        Product(
          id: 'drink-001',
          name: 'Water Bottle',
          sku: 'DRINK-001',
          unitCost: const MoneyRiel(1000),
          price: const MoneyRiel(2500),
          stock: 100,
        ),
        Product(
          id: 'drink-002',
          name: 'Fresh Orange Juice',
          sku: 'DRINK-002',
          unitCost: const MoneyRiel(4000),
          price: const MoneyRiel(9000),
          stock: 15,
        ),
        Product(
          id: 'pastry-001',
          name: 'Blueberry Muffin',
          sku: 'PASTRY-001',
          unitCost: const MoneyRiel(3500),
          price: const MoneyRiel(7500),
          stock: 18,
        ),
        Product(
          id: 'pastry-002',
          name: 'Chocolate Donut',
          sku: 'PASTRY-002',
          unitCost: const MoneyRiel(2500),
          price: const MoneyRiel(6000),
          stock: 22,
        ),
      ];

      for (final product in sampleProducts) {
        await productRepo.add(product);
      }

      // Set shop information for receipts
      await KeyValueService.set<String>('shop_name', 'KH POS Demo Shop');
      await KeyValueService.set<String>('shop_address', '123 Main Street, Phnom Penh, Cambodia');
      await KeyValueService.set<String>('shop_phone', '+855 12 345 678');
      await KeyValueService.set<String>('receipt_footer', 'Thank you for your business!');

      print('✅ Sample data seeded successfully!');
      print('📦 Added ${sampleProducts.length} sample products');
    } else {
      print('📦 Found ${existingProducts.length} existing products');
    }
  } catch (e) {
    print('❌ Error seeding sample data: $e');
  }
}