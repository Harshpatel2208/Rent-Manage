import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

/// Utility methods for formatting and parsing monetary values in Indian Rupees.
///
/// All monetary inputs and outputs use [Decimal] to prevent floating-point
/// precision errors in financial calculations.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  // ---------------------------------------------------------------------------
  // Formatters
  // ---------------------------------------------------------------------------

  /// Formats [amount] as Indian Rupees with full precision.
  ///
  /// Example: `Decimal.parse('100000')` → `'₹1,00,000.00'`
  static String formatINR(Decimal amount) =>
      _inrFormat.format(amount.toDouble());

  /// Formats [amount] compactly using Indian unit suffixes.
  ///
  /// Examples:
  /// - `Decimal.parse('100000')` → `'₹1L'`
  /// - `Decimal.parse('10000')` → `'₹10K'`
  static String formatCompact(Decimal amount) {
    final d = amount.toDouble();
    if (d >= 10000000) {
      return '₹${(d / 10000000).toStringAsFixed(1)}Cr';
    } else if (d >= 100000) {
      return '₹${(d / 100000).toStringAsFixed(1)}L';
    } else if (d >= 1000) {
      return '₹${(d / 1000).toStringAsFixed(1)}K';
    }
    return formatINR(amount);
  }

  // ---------------------------------------------------------------------------
  // Parser
  // ---------------------------------------------------------------------------

  /// Parses a user-entered [input] string into a [Decimal].
  ///
  /// Strips currency symbols, commas, and whitespace before parsing.
  /// Throws [FormatException] if the value cannot be parsed.
  static Decimal parseAmount(String input) {
    final cleaned = input
        .replaceAll('₹', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();
    if (cleaned.isEmpty) {
      throw const FormatException('Empty amount string');
    }
    return Decimal.parse(cleaned);
  }

  /// Like [parseAmount] but returns `null` instead of throwing.
  static Decimal? tryParseAmount(String input) {
    try {
      return parseAmount(input);
    } catch (_) {
      return null;
    }
  }
}
