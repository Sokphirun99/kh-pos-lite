import 'package:cashier_app/domain/entities/product.dart';
import 'package:cashier_app/domain/repositories/product_repository.dart';

/// Simple application service for products (create/edit/list).
class ProductsService {
  final ProductRepository repo;
  ProductsService(this.repo);

  Future<void> add(Product p) => repo.add(p);
  Future<void> update(Product p) => repo.update(p);
  Future<List<Product>> list() => repo.list();
}

