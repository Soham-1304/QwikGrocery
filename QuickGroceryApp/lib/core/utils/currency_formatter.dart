/// Currency formatting utilities for Indian Rupee (₹) amounts.
class CurrencyFormatter {
  const CurrencyFormatter._();

  /// Formats a cents/paise amount (e.g. 19900) into ₹199 or ₹199.00.
  static String formatCents(int cents, {bool showDecimals = false}) {
    final double rupees = cents / 100.0;
    return formatRupees(rupees, showDecimals: showDecimals);
  }

  /// Formats a rupee amount (e.g. 199.0) into ₹199 or ₹199.00.
  static String formatRupees(double rupees, {bool showDecimals = false}) {
    if (showDecimals || rupees % 1 != 0) {
      return '₹${rupees.toStringAsFixed(2)}';
    }
    return '₹${rupees.toInt()}';
  }

  /// Formats discount percentage badge text (e.g. "25% OFF").
  static String formatDiscount(int percent) {
    if (percent <= 0) return '';
    return '$percent% OFF';
  }

  /// Formats savings text (e.g. "Save ₹40").
  static String formatSavings(double savings) {
    if (savings <= 0) return '';
    return 'Save ${formatRupees(savings)}';
  }
}

/// Backward compatibility helper for legacy code expecting `money(int cents)`.
String money(int cents) => CurrencyFormatter.formatCents(cents, showDecimals: true);
