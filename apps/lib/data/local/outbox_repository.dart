import 'dart:convert';
import 'package:isar/isar.dart';
import 'isar_collections.dart';

class OutboxRepository {
  final Isar isar;
  OutboxRepository(this.isar);

  Future<void> enqueue({
    required String entity,
    required String op,
    required Map<String, dynamic> payload,
  }) async {
    final item = OutboxOp()
      ..createdAt = DateTime.now().toUtc()
      ..entity = entity
      ..op = op
      ..payloadJson = jsonEncode(payload)
      ..retryCount = 0;
    await isar.writeTxn(() async {
      await isar.outboxOps.put(item);
    });
  }

  Future<List<OutboxOp>> pending({int limit = 100}) async {
    return isar.outboxOps.where().sortByCreatedAt().limit(limit).findAll();
  }

  Future<void> remove(OutboxOp op) async {
    await isar.writeTxn(() async {
      await isar.outboxOps.delete(op.id);
    });
  }

  Future<void> incrementRetry(OutboxOp op) async {
    await isar.writeTxn(() async {
      op.retryCount += 1;
      await isar.outboxOps.put(op);
    });
  }
}
