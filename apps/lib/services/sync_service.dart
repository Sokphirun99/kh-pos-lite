import 'dart:convert';
import 'package:cashier_app/data/remote/api_client.dart';
import 'package:cashier_app/data/local/mappers/entity_mappers.dart';
import 'package:cashier_app/core/isar_db.dart';
import 'package:cashier_app/data/local/outbox_repository.dart';
import 'package:isar/isar.dart';
import 'package:cashier_app/data/remote/dtos/product_dto.dart';
import 'package:cashier_app/data/remote/dtos/sale_dto.dart';
import 'package:cashier_app/data/remote/dtos/payment_dto.dart';
import 'package:cashier_app/data/local/isar_collections.dart';
import 'package:cashier_app/services/key_value_service.dart';

// Handles push/pull queue and conflict resolution policy.
class SyncService {
  final ApiClient api;
  SyncService(this.api);

  Future<void> push() async {
    final Isar isar = await openIsarDb();
    final outbox = OutboxRepository(isar);
    final items = await outbox.pending(limit: 100);
    final enableBatch = KeyValueService.get<bool>('flag_enableBatchSync') ?? true;
    if (!enableBatch) {
      for (final op in items) {
        try {
          final body = jsonDecode(op.payloadJson);
          await api.post('/${op.entity}/${op.op}', data: body);
          await outbox.remove(op);
        } catch (_) {
          await outbox.incrementRetry(op);
        }
      }
      return;
    }
    final batchSize = (KeyValueService.get<int>('sync_batch_size') ?? 20).clamp(5, 50);
    for (var i = 0; i < items.length; i += batchSize) {
      final batch = items.sublist(i, i + batchSize > items.length ? items.length : i + batchSize);
      for (final op in batch) {
        try {
          final body = jsonDecode(op.payloadJson);
          await api.post('/${op.entity}/${op.op}', data: body);
          await outbox.remove(op);
        } catch (_) {
          await outbox.incrementRetry(op);
          final delay = Duration(seconds: 2 * (1 + op.retryCount).clamp(1, 10));
          await Future.delayed(delay);
        }
      }
    }
  }

  Future<void> pull() async {
    final isar = await openIsarDb();

    // Pull products
    final resProducts = await api.get<List<dynamic>>('/products');
    final listProducts = resProducts.data ?? <dynamic>[];
    await isar.writeTxn(() async {
      for (final j in listProducts) {
        final dto = ProductDto.fromJson(j as Map<String, dynamic>);
        final incomingUpdatedAt = DateTime.parse(dto.updatedAt).toUtc();
        final existing = await isar.productModels.filter().uidEqualTo(dto.id).findFirst();
        if (existing == null || existing.updatedAt.isBefore(incomingUpdatedAt)) {
          final model = dto.toDomain().toIsar()..updatedAt = incomingUpdatedAt;
          if (existing != null) model.id = existing.id;
          await isar.productModels.put(model);
        }
      }
    });
    // Tombstones for products
    try {
      final deletedProducts = await api.get<List<dynamic>>('/products/deleted');
      final delList = deletedProducts.data ?? <String>[];
      await isar.writeTxn(() async {
        for (final id in delList.cast<String>()) {
          final existing = await isar.productModels.filter().uidEqualTo(id).findFirst();
          if (existing != null) await isar.productModels.delete(existing.id);
        }
      });
    } catch (_) {}

    // Pull sales
    final resSales = await api.get<List<dynamic>>('/sales');
    final listSales = resSales.data ?? <dynamic>[];
    await isar.writeTxn(() async {
      for (final j in listSales) {
        final dto = SaleDto.fromJson(j as Map<String, dynamic>);
        final incomingUpdatedAt = DateTime.parse(dto.updatedAt).toUtc();
        final existing = await isar.saleModels.filter().uidEqualTo(dto.id).findFirst();
        if (existing == null || existing.updatedAt.isBefore(incomingUpdatedAt)) {
          final model = dto.toDomain().toIsar()..updatedAt = incomingUpdatedAt;
          if (existing != null) model.id = existing.id;
          await isar.saleModels.put(model);
        }
      }
    });
    // Tombstones for sales
    try {
      final deletedSales = await api.get<List<dynamic>>('/sales/deleted');
      final delList = deletedSales.data ?? <String>[];
      await isar.writeTxn(() async {
        for (final id in delList.cast<String>()) {
          final existing = await isar.saleModels.filter().uidEqualTo(id).findFirst();
          if (existing != null) await isar.saleModels.delete(existing.id);
        }
      });
    } catch (_) {}

    // Pull payments
    final resPayments = await api.get<List<dynamic>>('/payments');
    final listPayments = resPayments.data ?? <dynamic>[];
    await isar.writeTxn(() async {
      for (final j in listPayments) {
        final dto = PaymentDto.fromJson(j as Map<String, dynamic>);
        final incomingUpdatedAt = DateTime.parse(dto.updatedAt).toUtc();
        final existing = await isar.paymentModels.filter().uidEqualTo(dto.id).findFirst();
        if (existing == null || existing.updatedAt.isBefore(incomingUpdatedAt)) {
          final model = dto.toDomain().toIsar()..updatedAt = incomingUpdatedAt;
          if (existing != null) model.id = existing.id;
          await isar.paymentModels.put(model);
        }
      }
    });
    // Tombstones for payments
    try {
      final deletedPayments = await api.get<List<dynamic>>('/payments/deleted');
      final List<String> delList = (deletedPayments.data as List<dynamic>? ?? <dynamic>[]).cast<String>();
      await isar.writeTxn(() async {
        for (final id in delList) {
          final existing = await isar.paymentModels.filter().uidEqualTo(id).findFirst();
          if (existing != null) await isar.paymentModels.delete(existing.id);
        }
      });
    } catch (_) {}
  }
}
