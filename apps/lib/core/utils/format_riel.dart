import '../constants.dart';

/// Formats a number as Khmer Riel without external deps.
/// Example: 1234567 -> "1,234,567 ៛"
String formatRiel(num? amount) {
  if (amount == null) return '0 ${AppConstants.currencySymbol}';
  final intValue = amount.round();
  final s = intValue.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    buf.write(s[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
      buf.write(',');
    }
  }
  return '${buf.toString()} ${AppConstants.currencySymbol}';
}

