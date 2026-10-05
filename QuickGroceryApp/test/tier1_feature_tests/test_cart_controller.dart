import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_fixtures.dart';

Future<void> runCartControllerTests() async {
  await testGroup('Tier 1: Reactive Cart Controller Core', () async {
    await testCase('Initial cart has zero counts, zero totals, and no items', () {
      final cart = CartController();
      expect(cart.itemCount, equals(0));
      expect(cart.totalQuantity, equals(0));
      expect(cart.count, equals(0));
      expect(cart.subtotal, equals(0.0));
      expect(cart.mrpTotal, equals(0.0));
      expect(cart.mrpSavings, equals(0.0));
      expect(cart.deliveryFee, equals(0.0));
      expect(cart.packagingCharge, equals(0.0));
      expect(cart.total, equals(0.0));
      expect(cart.hasFreeDelivery, isFalse);
    });

    await testCase('add() adds a new product and computes subtotal and totalQuantity', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2);
      expect(cart.itemCount, equals(1));
      expect(cart.totalQuantity, equals(2));
      expect(cart.quantityOf(TestFixtures.p1Onions.id), equals(2));
      // Price 35 * 2 = 70.0
      expect(cart.subtotal, equals(70.0));
      // MRP 50 * 2 = 100.0 -> savings = 30.0
      expect(cart.mrpSavings, equals(30.0));
    });

    await testCase('increment() increments existing product quantity', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 1);
      cart.increment(TestFixtures.p1Onions);
      expect(cart.quantityOf(TestFixtures.p1Onions.id), equals(2));
      expect(cart.totalQuantity, equals(2));
    });

    await testCase('decrement() decrements quantity by 1', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 3);
      cart.decrement(TestFixtures.p1Onions.id);
      expect(cart.quantityOf(TestFixtures.p1Onions.id), equals(2));
      expect(cart.totalQuantity, equals(2));
    });

    await testCase('decrement() at quantity 1 removes the item from cart', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 1);
      cart.decrement(TestFixtures.p1Onions.id);
      expect(cart.itemCount, equals(0));
      expect(cart.quantityOf(TestFixtures.p1Onions.id), equals(0));
    });

    await testCase('setQuantity() updates item quantity directly', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 1);
      cart.setQuantity(TestFixtures.p1Onions.id, 5);
      expect(cart.quantityOf(TestFixtures.p1Onions.id), equals(5));
      expect(cart.totalQuantity, equals(5));
    });

    await testCase('setQuantity() with 0 or negative removes the item', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 3);
      cart.setQuantity(TestFixtures.p1Onions.id, 0);
      expect(cart.itemCount, equals(0));
    });

    await testCase('remove() removes product regardless of current quantity', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 5);
      cart.add(TestFixtures.p2Potatoes, quantity: 2);
      expect(cart.itemCount, equals(2));
      cart.remove(TestFixtures.p1Onions.id);
      expect(cart.itemCount, equals(1));
      expect(cart.quantityOf(TestFixtures.p1Onions.id), equals(0));
      expect(cart.quantityOf(TestFixtures.p2Potatoes.id), equals(2));
    });

    await testCase('clear() empties entire cart', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2);
      cart.add(TestFixtures.p4Milk, quantity: 3);
      cart.clear();
      expect(cart.itemCount, equals(0));
      expect(cart.totalQuantity, equals(0));
      expect(cart.subtotal, equals(0.0));
    });

    await testCase('hasFreeDelivery triggers when subtotal >= 199.0', () {
      final cart = CartController();
      // Add Milk: 68.0 -> not free delivery yet
      cart.add(TestFixtures.p4Milk, quantity: 1);
      expect(cart.hasFreeDelivery, isFalse);
      expect(cart.deliveryFee, equals(25.0));
      expect(cart.amountNeededForFreeDelivery, equals(131.0)); // 199 - 68

      // Add Atta: 260.0 -> total 328.0 >= 199.0
      cart.add(TestFixtures.p7Atta, quantity: 1);
      expect(cart.hasFreeDelivery, isTrue);
      expect(cart.deliveryFee, equals(0.0));
      expect(cart.amountNeededForFreeDelivery, equals(0.0));
    });

    await testCase('Grand total calculation includes packaging charge (₹10) and 5% taxes', () {
      final cart = CartController();
      // Subtotal = 100.0 (below free delivery threshold)
      // Custom calculation: let's add 2 units of p1Onions (70) and 1 of p3Tomatoes (25) + 1 chips (20) = 115.0
      cart.add(TestFixtures.p1Onions, quantity: 2); // 70
      cart.add(TestFixtures.p3Tomatoes, quantity: 1); // 25
      cart.add(TestFixtures.p10Chips, quantity: 1); // 20
      // subtotal = 115.0
      expect(cart.subtotal, equals(115.0));
      expect(cart.deliveryFee, equals(25.0));
      expect(cart.packagingCharge, equals(10.0));
      expect(cart.taxes, equals(115.0 * 0.05)); // 5.75
      // Total = 115.0 + 25.0 + 10.0 + 5.75 = 155.75
      expect(cart.total, equals(155.75));
    });

    await testCase('notifyListeners fires reactively on cart mutations', () {
      final cart = CartController();
      int notifyCount = 0;
      cart.addListener(() => notifyCount++);

      cart.add(TestFixtures.p1Onions);
      expect(notifyCount, equals(1));

      cart.increment(TestFixtures.p1Onions);
      expect(notifyCount, equals(2));

      cart.decrement(TestFixtures.p1Onions.id);
      expect(notifyCount, equals(3));

      cart.clear();
      expect(notifyCount, equals(4));
    });
  });
}

Future<void> main() async {
  await runCartControllerTests();
  globalTestSummary.printReport('Tier 1 CartController');
}
