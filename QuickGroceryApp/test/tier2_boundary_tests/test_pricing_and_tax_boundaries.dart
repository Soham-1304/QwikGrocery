import 'package:qwik_grocery_app/models/product.dart';
import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_fixtures.dart';

Future<void> runPricingAndTaxBoundariesTests() async {
  await testGroup('Tier 2: Pricing, Tax & Packaging Calculations Boundaries', () async {
    await testCase('Packaging charge is strictly fixed at ₹10.0 regardless of item quantity', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 1);
      expect(cart.packagingCharge, equals(10.0));

      cart.add(TestFixtures.p1Onions, quantity: 10);
      expect(cart.packagingCharge, equals(10.0));
    });

    await testCase('Taxes are calculated as exactly 5% of subtotal', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2); // 70.0
      expect(cart.taxes, equals(70.0 * 0.05)); // 3.50
    });

    await testCase('Empty cart has exactly 0.0 taxes', () {
      final cart = CartController();
      expect(cart.taxes, equals(0.0));
    });

    await testCase('High subtotal (e.g. ₹5000) calculates taxes and total accurately', () {
      final cart = CartController();
      const expensiveItem = Product(
        id: 'p_gold',
        name: 'Saffron Gift Box',
        category: 'Gifts',
        priceCents: 500000, // ₹5000.00
        imageUrl: '',
        description: '',
        stock: 5,
      );
      cart.add(expensiveItem, quantity: 1);
      expect(cart.subtotal, equals(5000.0));
      expect(cart.deliveryFee, equals(0.0)); // > 199
      expect(cart.packagingCharge, equals(10.0));
      expect(cart.taxes, equals(250.0)); // 5% of 5000
      expect(cart.total, equals(5260.0)); // 5000 + 0 + 10 + 250
    });

    await testCase('MRP savings evaluates to 0 when products have no discount', () {
      final cart = CartController();
      cart.add(TestFixtures.p10Chips, quantity: 3); // MRP = price = 20.0
      expect(cart.mrpSavings, equals(0.0));
    });

    await testCase('MRP savings scales linearly with item quantity', () {
      final cart = CartController();
      // Onions MRP = 50, Price = 35 -> savings = 15 per unit
      cart.add(TestFixtures.p1Onions, quantity: 1);
      expect(cart.mrpSavings, equals(15.0));

      cart.add(TestFixtures.p1Onions, quantity: 3); // total 4 units -> savings = 60.0
      expect(cart.mrpSavings, equals(60.0));
    });

    await testCase('MRP total is greater than or equal to subtotal for all standard items', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2);
      cart.add(TestFixtures.p2Potatoes, quantity: 2);
      expect(cart.mrpTotal >= cart.subtotal, isTrue);
    });

    await testCase('Subtotal in cents matches rupee subtotal multiplied by 100', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 3); // 105.0
      expect(cart.subtotalCents, equals(10500));
    });

    await testCase('Total calculation matches sum of individual bill components', () {
      final cart = CartController();
      cart.add(TestFixtures.p3Tomatoes, quantity: 2); // 50.0
      final expected = cart.subtotal + cart.deliveryFee + cart.packagingCharge + cart.taxes;
      expect(cart.total, equals(expected));
    });

    await testCase('Product savings property is never negative', () {
      for (final p in TestFixtures.allProducts) {
        expect(p.savings >= 0.0, isTrue);
        expect(p.savingsCents >= 0, isTrue);
      }
    });
  });
}

Future<void> main() async {
  await runPricingAndTaxBoundariesTests();
  globalTestSummary.printReport('Tier 2 PricingAndTaxBoundaries');
}
