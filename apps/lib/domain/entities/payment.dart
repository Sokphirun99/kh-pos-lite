import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/money_riel.dart';

part 'payment.freezed.dart';

@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String saleId,
    required String method, // cash, khqr, etc.
    required MoneyRiel amount,
  }) = _Payment;
}

