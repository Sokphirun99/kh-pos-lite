import 'package:flutter/foundation.dart';
import 'package:cashier_app/domain/repositories/payment_repository.dart';
import 'package:cashier_app/domain/entities/payment.dart';

/// Web-compatible in-memory implementation of PaymentRepository
/// This is a simple fallback for web platform where Isar has limitations
class WebPaymentRepositoryImpl implements PaymentRepository {
  static final Map<String, Payment> _payments = {};

  @override
  Future<void> add(Payment payment) async {
    _payments[payment.id] = payment;
    if (kDebugMode) {
      print('Web: Added payment ${payment.id}');
    }
  }

  @override
  Future<void> update(Payment payment) async {
    _payments[payment.id] = payment;
    if (kDebugMode) {
      print('Web: Updated payment ${payment.id}');
    }
  }

  @override
  Future<void> delete(String id) async {
    _payments.remove(id);
    if (kDebugMode) {
      print('Web: Deleted payment $id');
    }
  }

  @override
  Future<List<Payment>> list() async {
    return _payments.values.toList();
  }

  @override
  Future<Payment?> getById(String id) async {
    return _payments[id];
  }

  @override
  Stream<List<Payment>> watchAll() {
    // Return a stream that emits the current list
    return Stream.fromFuture(list());
  }
}