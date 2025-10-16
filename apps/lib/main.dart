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

/// Main entry point for the KH POS Lite application
///
/// This function initializes all required services and dependencies:
/// - Flutter framework and widgets binding
/// - BLoC pattern with HydratedBloc for state persistence
/// - Local database (Isar) for offline-first data storage
/// - Repository pattern for data access abstraction
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
