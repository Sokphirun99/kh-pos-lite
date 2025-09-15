import 'package:cashier_app/domain/entities/payment.dart';

abstract class PaymentRepository {
  Future<void> add(Payment payment);
  Future<void> update(Payment payment);
  Future<void> delete(String id);
  Future<List<Payment>> list();
  Future<Payment?> getById(String id);
  Stream<List<Payment>> watchAll();
}
