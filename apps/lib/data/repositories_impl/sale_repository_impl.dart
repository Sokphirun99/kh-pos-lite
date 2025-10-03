import 'dart:async';

import 'package:cashier_app/domain/entities/sale.dart';
import 'package:cashier_app/domain/repositories/sale_repository.dart';
import 'package:isar/isar.dart';
import '../local/isar_collections.dart';
import '../local/mappers/entity_mappers.dart';
import '../local/outbox_repository.dart';
import '../remote/api_paths.dart';

class SaleRepositoryImpl implements SaleRepository {
  final Isar isar;
  StreamController<List<Sale>>? _watchAllController;
  StreamSubscription<List<SaleModel>>? _watchAllSubscription;
  List<Sale>? _watchAllCache;
  SaleRepositoryImpl(this.isar);

  @override
  Future<void> add(Sale sale) async {
    await isar.writeTxn(() async {
      final existing = await isar.saleModels.filter().uidEqualTo(sale.id).findFirst();
      final model = sale.toIsar();
      if (existing != null) model.id = existing.id;
      await isar.saleModels.put(model);
    });
    await OutboxRepository(isar).enqueue(
      entity: ApiPaths.sales,
      op: ApiPaths.create,
      payload: sale.toDto().toJson(),
    );
  }

  @override
  Future<Sale?> getById(String id) async {
    final model = await isar.saleModels.filter().uidEqualTo(id).findFirst();
    return model?.toDomain();
  }

  @override
  Future<List<Sale>> list() async {
    final list = await isar.saleModels.where().sortByCreatedAt().findAll();
    return list.map((e) => e.toDomain()).toList(growable: false);
  }

  @override
  Future<void> update(Sale sale) async {
    await isar.writeTxn(() async {
      final existing = await isar.saleModels.filter().uidEqualTo(sale.id).findFirst();
      final model = sale.toIsar();
      if (existing != null) model.id = existing.id;
      await isar.saleModels.put(model);
    });
    await OutboxRepository(isar).enqueue(
      entity: ApiPaths.sales,
      op: ApiPaths.update,
      payload: sale.toDto().toJson(),
    );
  }

  @override
  Stream<List<Sale>> watchAll() {
    final existing = _watchAllController;
    if (existing != null) {
      return existing.stream;
    }

    final controller = StreamController<List<Sale>>.broadcast();
    controller
      ..onListen = () {
        final cached = _watchAllCache;
        if (cached != null) {
          controller.add(cached);
        }
      }
      ..onCancel = () async {
        if (!controller.hasListener) {
          await _watchAllSubscription?.cancel();
          _watchAllSubscription = null;
          _watchAllController = null;
        }
      };
    _watchAllController = controller;
    _watchAllSubscription = isar.saleModels
        .where()
        .sortByCreatedAt()
        .watch(fireImmediately: true)
        .listen((models) {
      final data = models.map((e) => e.toDomain()).toList(growable: false);
      _watchAllCache = data;
      controller.add(data);
    });
    return controller.stream;
  }

  @override
  Future<void> delete(String id) async {
    await isar.writeTxn(() async {
      final existing = await isar.saleModels.filter().uidEqualTo(id).findFirst();
      if (existing != null) {
        await isar.saleModels.delete(existing.id);
      }
    });
    await OutboxRepository(isar).enqueue(
      entity: ApiPaths.sales,
      op: ApiPaths.delete,
      payload: {'id': id},
    );
  }
}
