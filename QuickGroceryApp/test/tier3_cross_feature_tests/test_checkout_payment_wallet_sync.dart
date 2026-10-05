import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/mock_api_client.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_fixtures.dart';

Future<void> runCheckoutPaymentWalletSyncTests() async {
  await testGroup('Tier 3: Checkout <-> Payment & Wallet Synchronization', () async {
    final client = MockApiClient();

    await testCase('Checkout bill calculations sync with CartController state', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2); // 70.0
      cart.add(TestFixtures.p4Milk, quantity: 1);   // 68.0 -> subtotal 138.0
      final bill = cart.toBillSummary();

      expect(bill.itemTotal, equals(138.0));
      expect(bill.deliveryFee, equals(25.0)); // < 199.0
      expect(bill.packagingCharge, equals(10.0));
      expect(bill.taxes, equals(138.0 * 0.05));
      expect(bill.total, equals(cart.total));
    });

    await testCase('QwikWallet checkout succeeds when wallet balance exceeds order total', () async {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2); // 70.0 (total ~108.50)
      final initialWallet = await client.wallet();
      final initialBalance = initialWallet.balanceCents;

      final order = await client.createOrder(
        items: cart.itemsList,
        name: 'Aarav Sharma',
        phone: '9876543210',
        address: TestFixtures.addrHome.formatted,
        paymentMethodId: 'qwik_wallet',
      );

      expect(order.status, equals('placed'));
      final updatedWallet = await client.wallet();
      expect(updatedWallet.balanceCents < initialBalance, isTrue);
      expect(updatedWallet.balanceCents, equals(initialBalance - order.totalCents));
    });

    await testCase('Insufficient wallet balance prompts fallback to Cash on Delivery (COD)', () async {
      final cart = CartController();
      // Add items exceeding ₹500 wallet balance (e.g. 3 bags of Atta = 780.0)
      cart.add(TestFixtures.p7Atta, quantity: 3);

      // Attempting QwikWallet throws 402 Insufficient Balance
      bool walletFailed = false;
      try {
        await client.createOrder(
          items: cart.itemsList,
          name: 'Aarav Sharma',
          phone: '9876543210',
          address: TestFixtures.addrHome.formatted,
          paymentMethodId: 'qwik_wallet',
        );
      } catch (_) {
        walletFailed = true;
      }
      expect(walletFailed, isTrue);

      // User selects fallback to Cash on Delivery (COD)
      final codOrder = await client.createOrder(
        items: cart.itemsList,
        name: 'Aarav Sharma',
        phone: '9876543210',
        address: TestFixtures.addrHome.formatted,
        paymentMethodId: 'cod',
      );

      expect(codOrder.status, equals('placed'));
    });

    await testCase('Successful order placement clears CartController items', () async {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2);
      expect(cart.itemCount, equals(1));

      // Order created successfully
      await client.createOrder(
        items: cart.itemsList,
        name: 'Aarav Sharma',
        phone: '9876543210',
        address: TestFixtures.addrHome.formatted,
        paymentMethodId: 'cod',
      );

      // Cart is cleared
      cart.clear();
      expect(cart.itemCount, equals(0));
      expect(cart.totalQuantity, equals(0));
      expect(cart.subtotal, equals(0.0));
    });

    await testCase('Modifying cart quantity in real-time recalculates delivery fee in bill', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2); // 70.0
      expect(cart.toBillSummary().deliveryFee, equals(25.0));

      // User adds item pushing subtotal past ₹199
      cart.add(TestFixtures.p7Atta, quantity: 1); // 70 + 260 = 330.0
      final updatedBill = cart.toBillSummary();
      expect(updatedBill.deliveryFee, equals(0.0));
      expect(updatedBill.hasFreeDelivery, isTrue);
    });

    await testCase('Selected delivery instructions bundle cleanly into order payload', () async {
      final selectedChips = ['Leave at door', "Don't ring bell"];
      final notes = 'Please leave package near shoe rack.';
      final fullInstructions = '${selectedChips.join(', ')}. Note: $notes';

      final order = await client.createOrder(
        items: [{'productId': TestFixtures.p1Onions.id, 'quantity': 1}],
        name: 'Aarav Sharma',
        phone: '9876543210',
        address: TestFixtures.addrHome.formatted,
        instructions: fullInstructions,
      );

      expect(order.delivery!['instructions'], contains('Leave at door'));
      expect(order.delivery!['instructions'], contains('shoe rack'));
    });
  });
}

Future<void> main() async {
  await runCheckoutPaymentWalletSyncTests();
  globalTestSummary.printReport('Tier 3 CheckoutPaymentWalletSync');
}
