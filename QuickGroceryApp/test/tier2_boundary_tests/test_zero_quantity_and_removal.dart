import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_fixtures.dart';

Future<void> runZeroQuantityAndRemovalTests() async {
  await testGroup('Tier 2: 0-Quantity, Negatives & Item Removal Boundaries', () async {
    await testCase('Decrementing an item with quantity 1 removes it from cart', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 1);
      expect(cart.itemCount, equals(1));
      cart.decrement(TestFixtures.p1Onions.id);
      expect(cart.itemCount, equals(0));
      expect(cart.quantityOf(TestFixtures.p1Onions.id), equals(0));
      expect(cart.items.containsKey(TestFixtures.p1Onions.id), isFalse);
    });

    await testCase('Explicitly setting quantity to 0 removes the item', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 5);
      cart.setQuantity(TestFixtures.p1Onions.id, 0);
      expect(cart.itemCount, equals(0));
      expect(cart.quantityOf(TestFixtures.p1Onions.id), equals(0));
    });

    await testCase('Setting a negative quantity removes item without throwing exception', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 4);
      cart.setQuantity(TestFixtures.p1Onions.id, -2);
      expect(cart.itemCount, equals(0));
      expect(cart.quantityOf(TestFixtures.p1Onions.id), equals(0));
    });

    await testCase('Decrementing a non-existent product ID is a safe no-op', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2);
      // Decrement unknown ID
      cart.decrement('non_existent_id');
      expect(cart.itemCount, equals(1));
      expect(cart.quantityOf(TestFixtures.p1Onions.id), equals(2));
    });

    await testCase('Setting quantity on a non-existent product ID is a safe no-op', () {
      final cart = CartController();
      cart.setQuantity('phantom_product', 3);
      expect(cart.itemCount, equals(0));
      expect(cart.totalQuantity, equals(0));
    });

    await testCase('Removing a non-existent product ID is a safe no-op', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 1);
      int notifyCount = 0;
      cart.addListener(() => notifyCount++);
      cart.remove('unknown_id');
      expect(cart.itemCount, equals(1));
      // No listeners should be notified if nothing was removed
      expect(notifyCount, equals(0));
    });

    await testCase('add() with quantity 0 does not add item to cart', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 0);
      expect(cart.itemCount, equals(0));
      expect(cart.totalQuantity, equals(0));
    });

    await testCase('add() with negative quantity does not add item', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: -5);
      expect(cart.itemCount, equals(0));
    });

    await testCase('Removing an item isolates other items in cart', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2);
      cart.add(TestFixtures.p2Potatoes, quantity: 3);
      cart.add(TestFixtures.p4Milk, quantity: 1);
      expect(cart.itemCount, equals(3));

      cart.remove(TestFixtures.p2Potatoes.id);
      expect(cart.itemCount, equals(2));
      expect(cart.quantityOf(TestFixtures.p2Potatoes.id), equals(0));
      expect(cart.quantityOf(TestFixtures.p1Onions.id), equals(2));
      expect(cart.quantityOf(TestFixtures.p4Milk.id), equals(1));
    });

    await testCase('Calling clear() on already empty cart does not notify listeners', () {
      final cart = CartController();
      int notifyCount = 0;
      cart.addListener(() => notifyCount++);
      cart.clear();
      expect(notifyCount, equals(0));
    });
  });
}

Future<void> main() async {
  await runZeroQuantityAndRemovalTests();
  globalTestSummary.printReport('Tier 2 ZeroQuantityAndRemoval');
}
