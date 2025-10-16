// Web-compatible stub for entity mappers
// This implementation doesn't use Isar models

import 'package:cashier_app/domain/entities/product.dart';
import 'package:cashier_app/domain/entities/sale.dart';
import 'package:cashier_app/domain/entities/payment.dart';
import 'package:cashier_app/domain/value_objects/money_riel.dart';
import '../../remote/dtos/product_dto.dart';
import '../../remote/dtos/sale_dto.dart';
import '../../remote/dtos/payment_dto.dart';

// Since we're not using Isar on web, these extensions are not needed
// The web repositories use their own in-memory storage

// Product extensions (dummy implementations for web)
extension ProductToDto on Product {
  ProductDto toDto() {
    return ProductDto(
      id: id,
      name: name,
      sku: sku,
      unitCost: unitCost.amount,
      price: price.amount,
      stock: stock,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
}

extension ProductFromDto on ProductDto {
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      sku: sku,
      unitCost: MoneyRiel(unitCost),
      price: MoneyRiel(price),
      stock: stock,
    );
  }
}

// Sale extensions (dummy implementations for web)
extension SaleToDto on Sale {
  SaleDto toDto() {
    return SaleDto(
      id: id,
      createdAt: createdAt.toIso8601String(),
      total: total.amount,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
}

extension SaleFromDto on SaleDto {
  Sale toEntity() {
    return Sale(
      id: id,
      createdAt: DateTime.parse(createdAt),
      total: MoneyRiel(total),
    );
  }
}

// Payment extensions (dummy implementations for web)
extension PaymentToDto on Payment {
  PaymentDto toDto() {
    return PaymentDto(
      id: id,
      saleId: saleId,
      method: method,
      amount: amount.amount,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
}

extension PaymentFromDto on PaymentDto {
  Payment toEntity() {
    return Payment(
      id: id,
      saleId: saleId,
      method: method,
      amount: MoneyRiel(amount),
    );
  }
}
