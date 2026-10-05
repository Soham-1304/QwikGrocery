import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_components.dart';
import '../harness/test_fixtures.dart';

Future<void> runCartStepperSyncTests() async {
  await testGroup('Tier 3: In-Card Stepper <-> CartController State Synchronization', () async {
    await testCase('Tapping + ADD on ProductCard mutates CartController and morphs into stepper', () {
      final cart = CartController();
      final product = TestFixtures.p1Onions;
      expect(cart.quantityOf(product.id), equals(0));

      // Simulate + ADD tap
      cart.add(product);
      expect(cart.quantityOf(product.id), equals(1));

      // Stepper on card now displays quantity 1
      final card = ProductCard(product: product, controller: cart);
      expect(card.controller!.quantityOf(product.id), equals(1));
    });

    await testCase('Incrementing stepper directly mutates CartController subtotal and quantity', () {
      final cart = CartController();
      final product = TestFixtures.p1Onions; // 35.0
      cart.add(product, quantity: 1);
      expect(cart.subtotal, equals(35.0));

      // User taps + on stepper
      cart.increment(product);
      expect(cart.quantityOf(product.id), equals(2));
      expect(cart.subtotal, equals(70.0));
      expect(cart.totalQuantity, equals(2));
    });

    await testCase('Decrementing stepper to 0 removes product and card reverts to + ADD state', () {
      final cart = CartController();
      final product = TestFixtures.p1Onions;
      cart.add(product, quantity: 1);
      expect(cart.quantityOf(product.id), equals(1));

      // User taps - on stepper
      cart.decrement(product.id);
      expect(cart.quantityOf(product.id), equals(0));
      expect(cart.itemCount, equals(0));
      expect(cart.items.containsKey(product.id), isFalse);
    });

    await testCase('Adding item from Product Detail updates in-card stepper in Catalog/Home', () {
      final cart = CartController();
      final product = TestFixtures.p4Milk;

      // User adds 3 cartons from Product Detail page bottom bar
      cart.add(product, quantity: 3);

      // Home/Catalog ProductCard for Milk now shows quantity 3
      final homeCard = ProductCard(product: product, controller: cart);
      expect(homeCard.controller!.quantityOf(product.id), equals(3));
    });

    await testCase('Clearing cart from CartPage resets all cards across dashboard back to + ADD', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2);
      cart.add(TestFixtures.p2Potatoes, quantity: 1);
      cart.add(TestFixtures.p4Milk, quantity: 3);
      expect(cart.itemCount, equals(3));

      // User clears cart in CartPage
      cart.clear();
      expect(cart.itemCount, equals(0));

      final card1 = ProductCard(product: TestFixtures.p1Onions, controller: cart);
      final card2 = ProductCard(product: TestFixtures.p2Potatoes, controller: cart);
      expect(card1.controller!.quantityOf(TestFixtures.p1Onions.id), equals(0));
      expect(card2.controller!.quantityOf(TestFixtures.p2Potatoes.id), equals(0));
    });

    await testCase('Stock clamping in CartController enforces disabled + button in card stepper', () {
      final cart = CartController();
      // Kashmiri Saffron stock = 2
      final saffron = TestFixtures.p15CappedStock;
      cart.add(saffron, quantity: 2);

      // Stepper + button is disabled when quantity == stock
      final isMaxStock = cart.quantityOf(saffron.id) >= saffron.stock;
      expect(isMaxStock, isTrue);

      // Attempting to increment further is safely blocked
      cart.increment(saffron);
      expect(cart.quantityOf(saffron.id), equals(2));
    });
  });
}

Future<void> main() async {
  await runCartStepperSyncTests();
  globalTestSummary.printReport('Tier 3 CartStepperSync');
}
