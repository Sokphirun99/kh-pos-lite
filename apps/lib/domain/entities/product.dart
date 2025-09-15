import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/money_riel.dart';

part 'product.freezed.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String sku,
    required MoneyRiel unitCost,
    required MoneyRiel price,
    required int stock,
  }) = _Product;
}
