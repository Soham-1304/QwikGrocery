import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_fixtures.dart';

Future<void> runEmptyCartBoundariesTests() async {
  await testGroup('Tier 2: Empty Cart State Boundaries', () async {
    await testCase('Empty cart subtotal is exactly 0.0', () {
      final cart = CartController();
      expect(cart.subtotal, equals(0.0));
      expect(cart.subtotalCents, equals(0));
    });

    await testCase('Empty cart total is exactly 0.0 (no spurious fees)', () {
      final cart = CartController();
      expect(cart.total, equals(0.0));
    });

    await testCase('Empty cart delivery fee is 0.0, not ₹25.0', () {
      final cart = CartController();
      expect(cart.deliveryFee, equals(0.0));
    });

    await testCase('Empty cart packaging charge is 0.0, not ₹10.0', () {
      final cart = CartController();
      expect(cart.packagingCharge, equals(0.0));
    });

    await testCase('Empty cart taxes are 0.0', () {
      final cart = CartController();
      expect(cart.taxes, equals(0.0));
    });

    await testCase('Empty cart itemCount and totalQuantity are 0', () {
      final cart = CartController();
      expect(cart.itemCount, equals(0));
      expect(cart.totalQuantity, equals(0));
      expect(cart.items.isEmpty, isTrue);
    });

    await testCase('Empty cart freeDeliveryProgress is 0.0', () {
      final cart = CartController();
      expect(cart.freeDeliveryProgress, equals(0.0));
    });

    await testCase('Empty cart amountNeededForFreeDelivery is full threshold ₹199.0', () {
      final cart = CartController();
      expect(cart.amountNeededForFreeDelivery, equals(199.0));
      expect(cart.hasFreeDelivery, isFalse);
    });

    await testCase('Clearing a cart with items cleanly restores all 0-values', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2);
      cart.add(TestFixtures.p4Milk, quantity: 1);
      expect(cart.subtotal > 0, isTrue);

      cart.clear();
      expect(cart.subtotal, equals(0.0));
      expect(cart.total, equals(0.0));
      expect(cart.deliveryFee, equals(0.0));
      expect(cart.packagingCharge, equals(0.0));
      expect(cart.itemCount, equals(0));
    });

    await testCase('toBillSummary() on empty cart produces zeroed bill snapshot', () {
      final cart = CartController();
      final bill = cart.toBillSummary();
      expect(bill.itemTotal, equals(0.0));
      expect(bill.deliveryFee, equals(0.0));
      expect(bill.packagingCharge, equals(0.0));
      expect(bill.taxes, equals(0.0));
      expect(bill.total, equals(0.0));
    });
  });
}

Future<void> main() async {
  await runEmptyCartBoundariesTests();
  globalTestSummary.printReport('Tier 2 EmptyCartBoundaries');
}
