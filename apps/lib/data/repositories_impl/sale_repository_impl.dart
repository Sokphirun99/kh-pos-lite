import 'package:cashier_app/domain/entities/sale.dart';
import 'package:cashier_app/domain/repositories/sale_repository.dart';
import 'package:isar/isar.dart';
import '../local/isar_collections.dart';
import '../local/mappers/entity_mappers.dart';
import '../local/outbox_repository.dart';
import '../remote/api_paths.dart';

class SaleRepositoryImpl implements SaleRepository {
  final Isar isar;
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
    return isar.saleModels
        .where()
        .sortByCreatedAt()
        .watch(fireImmediately: true)
        .asyncMap((models) async => models.map((e) => e.toDomain()).toList(growable: false));
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
