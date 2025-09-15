import 'package:cashier_app/domain/entities/product.dart';
import 'package:cashier_app/domain/entities/sale.dart';
import 'package:cashier_app/domain/entities/payment.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';
import '../isar_collections.dart';
import '../../remote/dtos/product_dto.dart';
import '../../remote/dtos/sale_dto.dart';
import '../../remote/dtos/payment_dto.dart';

// Domain <-> Isar
extension ProductIsarMapper on Product {
  ProductModel toIsar() => ProductModel()
    ..uid = this.id
    ..name = this.name
    ..sku = this.sku
    ..unitCost = this.unitCost.amount
    ..price = this.price.amount
    ..stock = this.stock
    ..updatedAt = DateTime.now().toUtc();
}

extension ProductModelDomainMapper on ProductModel {
  Product toDomain() => Product(
        id: uid,
        name: name,
        sku: sku,
        unitCost: MoneyRiel(unitCost),
        price: MoneyRiel(price),
        stock: stock,
      );
}

extension SaleIsarMapper on Sale {
  SaleModel toIsar() => SaleModel()
    ..uid = this.id
    ..createdAt = this.createdAt
    ..total = this.total.amount
    ..updatedAt = DateTime.now().toUtc();
}

extension SaleModelDomainMapper on SaleModel {
  Sale toDomain() => Sale(id: uid, createdAt: createdAt, total: MoneyRiel(total));
}

extension PaymentIsarMapper on Payment {
  PaymentModel toIsar() => PaymentModel()
    ..uid = this.id
    ..saleUid = this.saleId
    ..method = this.method
    ..amount = this.amount.amount
    ..updatedAt = DateTime.now().toUtc();
}

extension PaymentModelDomainMapper on PaymentModel {
  Payment toDomain() =>
      Payment(id: uid, saleId: saleUid, method: method, amount: MoneyRiel(amount));
}

// Domain <-> DTO
extension ProductDtoMapper on Product {
  ProductDto toDto() => ProductDto(
        id: this.id,
        name: this.name,
        sku: this.sku,
        unitCost: this.unitCost.amount,
        price: this.price.amount,
        stock: this.stock,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      );
}

extension ProductFromDto on ProductDto {
  Product toDomain() => Product(
        id: this.id,
        name: this.name,
        sku: this.sku,
        unitCost: MoneyRiel(this.unitCost),
        price: MoneyRiel(this.price),
        stock: this.stock,
      );
}

extension SaleDtoMapper on Sale {
  SaleDto toDto() => SaleDto(
        id: this.id,
        createdAt: this.createdAt.toIso8601String(),
        total: this.total.amount,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      );
}

extension SaleFromDto on SaleDto {
  Sale toDomain() =>
      Sale(id: this.id, createdAt: DateTime.parse(this.createdAt), total: MoneyRiel(this.total));
}

extension PaymentDtoMapper on Payment {
  PaymentDto toDto() => PaymentDto(
        id: this.id,
        saleId: this.saleId,
        method: this.method,
        amount: this.amount.amount,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      );
}

extension PaymentFromDto on PaymentDto {
  Payment toDomain() =>
      Payment(id: this.id, saleId: this.saleId, method: this.method, amount: MoneyRiel(this.amount));
}
