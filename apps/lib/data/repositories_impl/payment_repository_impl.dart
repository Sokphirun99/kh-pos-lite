import 'dart:async';

import 'package:cashier_app/domain/entities/payment.dart';
import 'package:cashier_app/domain/repositories/payment_repository.dart';
import 'package:isar/isar.dart';
import '../local/isar_collections.dart';
import '../local/mappers/entity_mappers.dart';
import '../local/outbox_repository.dart';
import '../remote/api_paths.dart';
import 'package:cashier_app/services/key_value_service.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final Isar isar;
  StreamController<List<Payment>>? _watchAllController;
  StreamSubscription<List<PaymentModel>>? _watchAllSubscription;
  List<Payment>? _watchAllCache;
  PaymentRepositoryImpl(this.isar);

  @override
  Future<void> add(Payment payment) async {
    await isar.writeTxn(() async {
      final existing = await isar.paymentModels
          .filter()
          .uidEqualTo(payment.id)
          .findFirst();
      final model = payment.toIsar();
      if (existing != null) model.id = existing.id;
      await isar.paymentModels.put(model);
    });
    await OutboxRepository(isar).enqueue(
      entity: ApiPaths.payments,
      op: ApiPaths.create,
      payload: payment.toDto().toJson(),
    );
  }

  @override
  Future<Payment?> getById(String id) async {
    final model = await isar.paymentModels.filter().uidEqualTo(id).findFirst();
    return model?.toDomain();
  }

  @override
  Future<List<Payment>> list() async {
    final list = await isar.paymentModels.where().findAll();
    return list.map((e) => e.toDomain()).toList(growable: false);
  }

  @override
  Future<void> update(Payment payment) async {
    await isar.writeTxn(() async {
      final existing = await isar.paymentModels
          .filter()
          .uidEqualTo(payment.id)
          .findFirst();
      final model = payment.toIsar();
      if (existing != null) model.id = existing.id;
      await isar.paymentModels.put(model);
    });
    await OutboxRepository(isar).enqueue(
      entity: ApiPaths.payments,
      op: ApiPaths.update,
      payload: payment.toDto().toJson(),
    );
  }

  @override
  Stream<List<Payment>> watchAll() {
    final existing = _watchAllController;
    if (existing != null) {
      return existing.stream;
    }

    final controller = StreamController<List<Payment>>.broadcast();
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
    _watchAllSubscription = isar.paymentModels
        .where()
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
      final existing = await isar.paymentModels
          .filter()
          .uidEqualTo(id)
          .findFirst();
      if (existing != null) {
        await isar.paymentModels.delete(existing.id);
      }
    });
    await OutboxRepository(isar).enqueue(
      entity: ApiPaths.payments,
      op: ApiPaths.delete,
      payload: {'id': id},
    );
    // Clean up any locally stored tx reference for this payment
    try {
      await KeyValueService.remove('payment_ref_$id');
    } catch (_) {
      // Ignore if KV service not initialized (e.g., tests)
    }
  }
}
