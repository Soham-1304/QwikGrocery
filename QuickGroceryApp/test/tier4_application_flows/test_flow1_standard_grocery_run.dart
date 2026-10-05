import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/mock_api_client.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_fixtures.dart';

Future<void> runFlow1StandardGroceryRunTests() async {
  await testGroup('Tier 4 Flow 1: Standard Grocery Run (Discovery -> Threshold Met -> UPI -> Confirmation)', () async {
    final client = MockApiClient();

    await testCase('Step 1-3: User discovers items and adds to cart with in-card steppers', () async {
      final cart = CartController();

      // User filters catalog by Vegetables
      final veggies = await client.products(category: 'Vegetables');
      expect(veggies.isNotEmpty, isTrue);

      // User adds 2 kg Farm Fresh Onions (35 * 2 = 70)
      final onions = veggies.firstWhere((p) => p.id == 'prod_onions');
      cart.add(onions, quantity: 1);
      cart.increment(onions); // In-card stepper tap
      expect(cart.quantityOf(onions.id), equals(2));

      // User adds 1 kg Organic Potatoes (40)
      final potatoes = veggies.firstWhere((p) => p.id == 'prod_potatoes');
      cart.add(potatoes, quantity: 1);
      expect(cart.quantityOf(potatoes.id), equals(1));

      // User searches Atta in catalog and adds 5 kg bag (260)
      final staples = await client.products(search: 'atta');
      final atta = staples.first;
      cart.add(atta, quantity: 1);
      expect(cart.quantityOf(atta.id), equals(1));

      // Subtotal = 70 + 40 + 260 = 370.0
      expect(cart.subtotal, equals(370.0));
      expect(cart.totalQuantity, equals(4));
    });

    await testCase('Step 4: User reviews cart and verifies FREE delivery threshold met', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2); // 70
      cart.add(TestFixtures.p2Potatoes, quantity: 1); // 40
      cart.add(TestFixtures.p7Atta, quantity: 1); // 260
      // Subtotal = 370.0 >= 199.0
      expect(cart.hasFreeDelivery, isTrue);
      expect(cart.deliveryFee, equals(0.0));
      expect(cart.amountNeededForFreeDelivery, equals(0.0));
      expect(cart.freeDeliveryProgress, equals(1.0));

      final bill = cart.toBillSummary();
      expect(bill.itemTotal, equals(370.0));
      expect(bill.deliveryFee, equals(0.0));
      expect(bill.packagingCharge, equals(10.0));
      expect(bill.taxes, equals(370.0 * 0.05)); // 18.50
      // Total = 370.0 + 0.0 + 10.0 + 18.50 = 398.50
      expect(bill.total, equals(398.50));
    });

    await testCase('Step 5-6: User selects Home address, UPI payment, instructions and places order', () async {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2);
      cart.add(TestFixtures.p2Potatoes, quantity: 1);
      cart.add(TestFixtures.p7Atta, quantity: 1);

      final profile = await client.profile();
      final homeAddr = profile.addresses.firstWhere((a) => a.label == 'Home');
      final upiMethod = profile.paymentMethods.firstWhere((pm) => pm.type == 'upi');

      // Place order via API
      final order = await client.createOrder(
        items: cart.itemsList,
        name: profile.name,
        phone: homeAddr.phone,
        address: homeAddr.formatted,
        addressId: homeAddr.id,
        paymentMethodId: upiMethod.id,
        instructions: 'Leave at door. Don\'t ring bell.',
      );

      // Verify order confirmation details
      expect(order.id.startsWith('ORD-'), isTrue);
      expect(order.status, equals('placed'));
      expect(order.items.length, equals(3));
      expect(order.delivery!['partnerName'], isNotNull);
      expect(order.delivery!['etaMinutes'], equals(12));
      expect(order.delivery!['instructions'], contains('Leave at door'));

      // Cart is cleared after order
      cart.clear();
      expect(cart.itemCount, equals(0));
    });
  });
}

Future<void> main() async {
  await runFlow1StandardGroceryRunTests();
  globalTestSummary.printReport('Tier 4 Flow 1');
}
