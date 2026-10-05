import 'package:qwik_grocery_app/models/wallet.dart';
import 'package:qwik_grocery_app/services/api_exception.dart';
import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/mock_api_client.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_fixtures.dart';

Future<void> runFlow5WalletAndFallbackCodTests() async {
  await testGroup('Tier 4 Flow 5: QwikWallet Checkout & COD Fallback Journey', () async {
    await testCase('User completes seamless checkout paying via QwikWallet with verified balance deduction', () async {
      // Seed wallet with ₹250.00 (25000 cents)
      final client = MockApiClient(
        seedWallet: const WalletSummary(
          balanceCents: 25000,
          transactions: [],
        ),
      );
      final cart = CartController();

      // Check initial wallet balance: ₹250.00
      final initialWallet = await client.wallet();
      expect(initialWallet.balanceCents, equals(25000));
      expect(initialWallet.balanceCents / 100, equals(250.0));

      // User adds milk (₹68) and curd (₹35)
      final milk = await client.product('prod_milk');
      final curd = await client.product('prod_curd');
      cart.add(milk);
      cart.add(curd);

      expect(cart.subtotal, equals(103.0));
      // Under ₹199 threshold: delivery fee = ₹25.0
      expect(cart.deliveryFee, equals(25.0));

      // Place order using QwikWallet
      final order = await client.createOrder(
        items: cart.items.values.toList(),
        name: TestFixtures.profile.name,
        phone: '9876543210',
        address: TestFixtures.addrHome.formatted,
        paymentMethodId: 'qwik_wallet',
      );

      expect(order.status, equals('placed'));
      expect(order.items.length, equals(2));

      // Expected cents: subtotal 10300 + delivery 2500 + packaging 1000 + tax round(10300 * 0.05 = 515) = 14315
      expect(order.totalCents, equals(14315));

      // Verify wallet balance is deducted
      final updatedWallet = await client.wallet();
      expect(updatedWallet.balanceCents, equals(25000 - 14315));
      expect(updatedWallet.balanceCents, equals(10685));
      expect(updatedWallet.transactions.first.type, equals('debit'));
      expect(updatedWallet.transactions.first.amountCents, equals(14315));

      // Cart can be cleared post-checkout
      cart.clear();
      expect(cart.items.isEmpty, isTrue);
    });

    await testCase('User attempts checkout with insufficient QwikWallet balance, encounters 402 rejection, and falls back to Cash on Delivery (COD)', () async {
      // Wallet balance seeded with ₹250.00 (25000 cents)
      final client = MockApiClient(
        seedWallet: const WalletSummary(
          balanceCents: 25000,
          transactions: [],
        ),
      );
      final cart = CartController();

      final initialWallet = await client.wallet();
      expect(initialWallet.balanceCents, equals(25000));

      // User builds a high-value cart exceeding wallet balance:
      // Atta (₹260) + Almonds (₹249) = ₹509.00
      final atta = await client.product('prod_atta');
      final almonds = await client.product('prod_almonds');
      cart.add(atta);
      cart.add(almonds);

      expect(cart.subtotal, equals(509.0));
      expect(cart.hasFreeDelivery, isTrue);

      // Attempt payment with QwikWallet -> should fail with 402 Insufficient wallet balance
      bool rejectedForFunds = false;
      try {
        await client.createOrder(
          items: cart.items.values.toList(),
          name: TestFixtures.profile.name,
          phone: '9876543210',
          address: TestFixtures.addrWork.formatted,
          paymentMethodId: 'qwik_wallet',
        );
      } on ApiException catch (e) {
        if (e.statusCode == 402 && e.message.contains('Insufficient wallet balance')) {
          rejectedForFunds = true;
        }
      }
      expect(rejectedForFunds, isTrue);

      // Cart items remain intact and wallet balance is untouched
      expect(cart.itemCount, equals(2));
      final currentWallet = await client.wallet();
      expect(currentWallet.balanceCents, equals(25000));

      // User selects COD fallback and places order
      final codOrder = await client.createOrder(
        items: cart.items.values.toList(),
        name: TestFixtures.profile.name,
        phone: '9876543210',
        address: TestFixtures.addrWork.formatted,
        paymentMethodId: 'cash_on_delivery',
        instructions: 'Leave at reception desk',
      );

      expect(codOrder.status, equals('placed'));
      expect(codOrder.delivery?['instructions'], equals('Leave at reception desk'));

      // Total cents: 50900 + 0 delivery + 1000 packaging + round(50900 * 0.05 = 2545) tax = 54445
      expect(codOrder.totalCents, equals(54445));

      // Wallet balance remains 100% intact after COD order
      final postCodWallet = await client.wallet();
      expect(postCodWallet.balanceCents, equals(25000));

      cart.clear();
      expect(cart.items.isEmpty, isTrue);
    });
  });
}

Future<void> main() async {
  await runFlow5WalletAndFallbackCodTests();
  globalTestSummary.printReport('Tier 4 Flow 5');
}
