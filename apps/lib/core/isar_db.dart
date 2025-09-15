import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cashier_app/data/local/isar_collections.dart';
import 'migrations.dart';

Future<Isar> openIsarDb({String? directory}) async {
  if (Isar.instanceNames.isNotEmpty) {
    return Isar.getInstance()!;
  }
  Directory dir;
  if (directory != null) {
    dir = Directory(directory);
  } else if (kIsWeb) {
    dir = Directory.current;
  } else {
    dir = await getApplicationDocumentsDirectory();
  }
  final isar = await Isar.open(
    [ProductModelSchema, SaleModelSchema, PaymentModelSchema, OutboxOpSchema, MetaKVSchema],
    directory: dir.path,
    inspector: false,
  );
  await runMigrations(isar);
  return isar;
}
