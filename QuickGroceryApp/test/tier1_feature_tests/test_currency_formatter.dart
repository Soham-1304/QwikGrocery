import 'package:qwik_grocery_app/core/utils/currency_formatter.dart';
import '../harness/test_app_harness.dart';

Future<void> runCurrencyFormatterTests() async {
  await testGroup('Tier 1: Currency Formatter & Utilities', () async {
    await testCase('formatCents converts paise without decimals for integer rupees', () {
      expect(CurrencyFormatter.formatCents(19900), equals('₹199'));
      expect(CurrencyFormatter.formatCents(5000), equals('₹50'));
      expect(CurrencyFormatter.formatCents(0), equals('₹0'));
    });

    await testCase('formatCents converts fractional paise with two decimals', () {
      expect(CurrencyFormatter.formatCents(19950), equals('₹199.50'));
      expect(CurrencyFormatter.formatCents(3525), equals('₹35.25'));
    });

    await testCase('formatCents with showDecimals: true forces two decimals', () {
      expect(CurrencyFormatter.formatCents(19900, showDecimals: true), equals('₹199.00'));
      expect(CurrencyFormatter.formatCents(0, showDecimals: true), equals('₹0.00'));
    });

    await testCase('formatRupees formats integer and floating rupees correctly', () {
      expect(CurrencyFormatter.formatRupees(299.0), equals('₹299'));
      expect(CurrencyFormatter.formatRupees(299.5), equals('₹299.50'));
      expect(CurrencyFormatter.formatRupees(299.0, showDecimals: true), equals('₹299.00'));
    });

    await testCase('formatDiscount generates discount percentage badge string', () {
      expect(CurrencyFormatter.formatDiscount(30), equals('30% OFF'));
      expect(CurrencyFormatter.formatDiscount(50), equals('50% OFF'));
    });

    await testCase('formatDiscount returns empty string for 0 or negative discounts', () {
      expect(CurrencyFormatter.formatDiscount(0), equals(''));
      expect(CurrencyFormatter.formatDiscount(-10), equals(''));
    });

    await testCase('formatSavings formats savings text', () {
      expect(CurrencyFormatter.formatSavings(40.0), equals('Save ₹40'));
      expect(CurrencyFormatter.formatSavings(45.5), equals('Save ₹45.50'));
      expect(CurrencyFormatter.formatSavings(0.0), equals(''));
    });

    await testCase('legacy money() helper preserves backward compatibility', () {
      expect(money(29900), equals('₹299.00'));
      expect(money(0), equals('₹0.00'));
    });
  });
}

Future<void> main() async {
  await runCurrencyFormatterTests();
  globalTestSummary.printReport('Tier 1 CurrencyFormatter');
}
