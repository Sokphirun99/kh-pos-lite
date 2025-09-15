import '../entities/product.dart';

abstract class ProductRepository {
  Future<void> add(Product product);
  Future<void> update(Product product);
  Future<void> delete(String id);
  Future<List<Product>> list();
  Future<Product?> getById(String id);
  Stream<List<Product>> watchAll();
}
