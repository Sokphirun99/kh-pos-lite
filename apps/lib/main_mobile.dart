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
// import 'background/sync_task.dart';
// import 'package:workmanager/workmanager.dart';
import 'services/key_value_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  Bloc.observer = AppBlocObserver();

  // Initialize lightweight key-value storage (Hive)
  await KeyValueService.init();

  // Initialize Isar database for mobile/desktop platforms
  final isar = await openIsarDb();
  final ProductRepository productsRepo = ProductRepositoryImpl(isar);
  final SaleRepository salesRepo = SaleRepositoryImpl(isar);
  final PaymentRepository paymentsRepo = PaymentRepositoryImpl(isar);

  // TODO: Initialize workmanager for background sync (mobile only)
  // await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  // await Workmanager().registerPeriodicTask(
  //   'syncPeriodic',
  //   syncTaskName,
  //   frequency: const Duration(minutes: 15),
  //   existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  //   constraints: Constraints(
  //     networkType: NetworkType.connected,
  //     requiresBatteryNotLow: true,
  //   ),
  //   backoffPolicy: BackoffPolicy.exponential,
  //   backoffPolicyDelay: const Duration(minutes: 5),
  // );

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