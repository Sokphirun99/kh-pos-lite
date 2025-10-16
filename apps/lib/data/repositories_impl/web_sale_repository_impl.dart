import 'package:flutter/foundation.dart';
import 'package:cashier_app/domain/repositories/sale_repository.dart';
import 'package:cashier_app/domain/entities/sale.dart';

/// Web-compatible in-memory implementation of SaleRepository
/// This is a simple fallback for web platform where Isar has limitations
class WebSaleRepositoryImpl implements SaleRepository {
  static final Map<String, Sale> _sales = {};

  @override
  Future<void> add(Sale sale) async {
    _sales[sale.id] = sale;
    if (kDebugMode) {
      print('Web: Added sale ${sale.id}');
    }
  }

  @override
  Future<void> update(Sale sale) async {
    _sales[sale.id] = sale;
    if (kDebugMode) {
      print('Web: Updated sale ${sale.id}');
    }
  }

  @override
  Future<void> delete(String id) async {
    _sales.remove(id);
    if (kDebugMode) {
      print('Web: Deleted sale $id');
    }
  }

  @override
  Future<List<Sale>> list() async {
    return _sales.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Sale?> getById(String id) async {
    return _sales[id];
  }

  @override
  Stream<List<Sale>> watchAll() {
    // Return a stream that emits the current list
    return Stream.fromFuture(list());
  }
}
