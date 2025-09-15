import 'package:cashier_app/domain/repositories/product_repository.dart';
import 'package:cashier_app/domain/entities/product.dart';
import 'package:isar/isar.dart';
import '../local/isar_collections.dart';
import '../local/mappers/entity_mappers.dart';
import '../local/outbox_repository.dart';
import '../remote/api_paths.dart';

/// Placeholder implementation wiring to local/remote sources later.
class ProductRepositoryImpl implements ProductRepository {
  final Isar isar;
  ProductRepositoryImpl(this.isar);

  @override
  Future<void> add(Product product) async {
    await isar.writeTxn(() async {
      final existing = await isar.productModels.filter().uidEqualTo(product.id).findFirst();
      final model = product.toIsar();
      if (existing != null) model.id = existing.id;
      await isar.productModels.put(model);
    });
    // Enqueue outbox op for sync
    await OutboxRepository(isar).enqueue(
      entity: ApiPaths.products,
      op: ApiPaths.create,
      payload: product.toDto().toJson(),
    );
  }

  @override
  Future<Product?> getById(String id) async {
    final model = await isar.productModels.filter().uidEqualTo(id).findFirst();
    return model?.toDomain();
  }

  @override
  Future<Product?> getBySku(String sku) async {
    final model = await isar.productModels.filter().skuEqualTo(sku).findFirst();
    return model?.toDomain();
  }

  @override
  Future<List<Product>> list() async {
    final list = await isar.productModels.where().sortByName().findAll();
    return list.map((e) => e.toDomain()).toList(growable: false);
  }

  @override
  Future<void> update(Product product) async {
    await isar.writeTxn(() async {
      final existing = await isar.productModels.filter().uidEqualTo(product.id).findFirst();
      final model = product.toIsar();
      if (existing != null) model.id = existing.id;
      await isar.productModels.put(model);
    });
    await OutboxRepository(isar).enqueue(
      entity: ApiPaths.products,
      op: ApiPaths.update,
      payload: product.toDto().toJson(),
    );
  }

  @override
  Future<void> delete(String id) async {
    await isar.writeTxn(() async {
      final existing = await isar.productModels.filter().uidEqualTo(id).findFirst();
      if (existing != null) {
        await isar.productModels.delete(existing.id);
      }
    });
    await OutboxRepository(isar).enqueue(
      entity: ApiPaths.products,
      op: ApiPaths.delete,
      payload: {'id': id},
    );
  }

  @override
  Stream<List<Product>> watchAll() {
    return isar.productModels
        .where()
        .sortByName()
        .watch(fireImmediately: true)
        .asyncMap((models) async => models.map((e) => e.toDomain()).toList(growable: false));
  }
}
