import '../entities/product.dart';

abstract class ProductRepository {
  Future<void> add(Product product);
  Future<void> update(Product product);
  Future<void> delete(String id);
  Future<List<Product>> list();
  Future<Product?> getById(String id);
  Future<Product?> getBySku(String sku);
  Stream<List<Product>> watchAll();
}
