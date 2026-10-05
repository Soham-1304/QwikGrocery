import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/mock_api_client.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_fixtures.dart';

Future<void> runFlow3OutOfStockAndCapsTests() async {
  await testGroup('Tier 4 Flow 3: Out-of-Stock Protection & Stock Limit Cap', () async {
    final client = MockApiClient();

    await testCase('User cannot add out-of-stock product to cart', () async {
      final cart = CartController();
      // Blueberries has stock = 0
      final berries = TestFixtures.p14OutOfStock;
      expect(berries.available, isFalse);
      expect(berries.stock, equals(0));

      // Attempt tap add
      cart.add(berries);
      expect(cart.quantityOf(berries.id), equals(0));
      expect(cart.itemCount, equals(0));

      // Attempt increment
      cart.increment(berries);
      expect(cart.quantityOf(berries.id), equals(0));
    });

    await testCase('User adding capped stock item (Saffron stock=2) cannot exceed 2 units and checks out with 2', () async {
      final cart = CartController();
      final saffron = TestFixtures.p15CappedStock; // stock: 2, price: 199.0

      // Step 1: User adds 1 unit
      cart.add(saffron, quantity: 1);
      expect(cart.quantityOf(saffron.id), equals(1));

      // Step 2: User taps + on stepper -> quantity = 2
      cart.increment(saffron);
      expect(cart.quantityOf(saffron.id), equals(2));

      // Step 3: User attempts to tap + again -> clamped at 2
      cart.increment(saffron);
      expect(cart.quantityOf(saffron.id), equals(2));

      // User checks out with exactly 2 units
      final order = await client.createOrder(
        items: cart.itemsList,
        name: 'Aarav Sharma',
        phone: '9876543210',
        address: TestFixtures.addrHome.formatted,
        paymentMethodId: 'cod',
      );

      expect(order.status, equals('placed'));
      expect(order.items.first['quantity'], equals(2));
      expect(order.items.first['productId'], equals(saffron.id));
    });
  });
}

Future<void> main() async {
  await runFlow3OutOfStockAndCapsTests();
  globalTestSummary.printReport('Tier 4 Flow 3');
}
