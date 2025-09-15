import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

Future<void> testExecutable(FutureOr<void> Function() main) async {
  // Initialize Isar for tests before running any tests
  await Isar.initializeIsarCore(download: true);
  
  // Now, run the main test function
  await main();
}
