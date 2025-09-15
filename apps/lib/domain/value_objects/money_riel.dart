import 'package:meta/meta.dart';

@immutable
class MoneyRiel {
  final int amount; // stored in Riel as integer

  const MoneyRiel(this.amount) : assert(amount >= 0, 'amount must be >= 0');

  MoneyRiel operator +(MoneyRiel other) => MoneyRiel(amount + other.amount);
  MoneyRiel operator -(MoneyRiel other) => MoneyRiel((amount - other.amount).clamp(0, 1 << 62));

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MoneyRiel && runtimeType == other.runtimeType && amount == other.amount;

  @override
  int get hashCode => amount.hashCode;

  @override
  String toString() => 'MoneyRiel($amount)';
}

