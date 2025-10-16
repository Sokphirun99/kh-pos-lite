import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/money_riel.dart';

part 'sale.freezed.dart';

@freezed
class Sale with _$Sale {
  const factory Sale({
    required String id,
    required DateTime createdAt,
    required MoneyRiel total,
  }) = _Sale;
}
