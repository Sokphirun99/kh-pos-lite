import 'package:flutter/foundation.dart';
import 'package:cashier_app/domain/repositories/product_repository.dart';
import 'package:cashier_app/domain/entities/product.dart';

/// Web-compatible in-memory implementation of ProductRepository
/// This is a simple fallback for web platform where Isar has limitations
class WebProductRepositoryImpl implements ProductRepository {
  static final Map<String, Product> _products = {};

  @override
  Future<void> add(Product product) async {
    _products[product.id] = product;
    if (kDebugMode) {
      print('Web: Added product ${product.id}');
    }
  }

  @override
  Future<void> update(Product product) async {
    _products[product.id] = product;
    if (kDebugMode) {
      print('Web: Updated product ${product.id}');
    }
  }

  @override
  Future<void> delete(String id) async {
    _products.remove(id);
    if (kDebugMode) {
      print('Web: Deleted product $id');
    }
  }

  @override
  Future<List<Product>> list() async {
    return _products.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<Product?> getById(String id) async {
    return _products[id];
  }

  @override
  Future<Product?> getBySku(String sku) async {
    return _products.values.where((p) => p.sku == sku).firstOrNull;
  }

  @override
  Stream<List<Product>> watchAll() {
    // Return a stream that emits the current list
    return Stream.fromFuture(list());
  }
}
