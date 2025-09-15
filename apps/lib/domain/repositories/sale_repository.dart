import 'package:cashier_app/domain/entities/sale.dart';

abstract class SaleRepository {
  Future<void> add(Sale sale);
  Future<void> update(Sale sale);
  Future<void> delete(String id);
  Future<List<Sale>> list();
  Future<Sale?> getById(String id);
  Stream<List<Sale>> watchAll();
}
