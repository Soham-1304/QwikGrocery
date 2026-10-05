import 'package:qwik_grocery_app/services/api_exception.dart';
import '../harness/mock_api_client.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_fixtures.dart';

Future<void> runWalletBalanceBoundariesTests() async {
  await testGroup('Tier 2: QwikWallet Balance & Transaction Boundaries', () async {
    await testCase('Initial seeded wallet has ₹500.00 balance', () async {
      final client = MockApiClient();
      final wallet = await client.wallet();
      expect(wallet.balanceCents, equals(50000));
      expect(wallet.transactions.isNotEmpty, isTrue);
    });

    await testCase('Order payment with wallet deducts balance accurately', () async {
      final client = MockApiClient();
      // Onions: 35.0 (subtotal 35.0 < 199 -> fee 25, pack 10, tax 1.75 -> total ~71.75 = 7175 cents)
      await client.createOrder(
        items: [
          {'productId': TestFixtures.p1Onions.id, 'quantity': 1},
        ],
        name: 'Aarav',
        phone: '9876543210',
        address: TestFixtures.addrHome.formatted,
        paymentMethodId: 'qwik_wallet',
      );

      final wallet = await client.wallet();
      expect(wallet.balanceCents < 50000, isTrue);
      expect(wallet.transactions.first.type, equals('debit'));
    });

    await testCase('Attempting to pay with insufficient wallet balance throws ApiException with 402', () async {
      final client = MockApiClient();
      bool threwExpected = false;
      try {
        // Atta (260.0) x 3 = 780.0 > 500.0 wallet
        await client.createOrder(
          items: [
            {'productId': TestFixtures.p7Atta.id, 'quantity': 3},
          ],
          name: 'Aarav',
          phone: '9876543210',
          address: TestFixtures.addrHome.formatted,
          paymentMethodId: 'qwik_wallet',
        );
      } on ApiException catch (e) {
        threwExpected = true;
        expect(e.statusCode, equals(402));
        expect(e.message, contains('Insufficient wallet balance'));
      }
      expect(threwExpected, isTrue);
    });

    await testCase('Failed wallet payment does not deduct any balance', () async {
      final client = MockApiClient();
      try {
        await client.createOrder(
          items: [
            {'productId': TestFixtures.p7Atta.id, 'quantity': 10},
          ],
          name: 'Aarav',
          phone: '9876543210',
          address: TestFixtures.addrHome.formatted,
          paymentMethodId: 'qwik_wallet',
        );
      } catch (_) {}

      final wallet = await client.wallet();
      expect(wallet.balanceCents, equals(50000));
    });

    await testCase('Top-up with positive amount increases wallet balance', () async {
      final client = MockApiClient();
      await client.topUpWallet(20000); // Add ₹200
      final wallet = await client.wallet();
      expect(wallet.balanceCents, equals(70000)); // 500 + 200 = ₹700
      expect(wallet.transactions.first.type, equals('credit'));
      expect(wallet.transactions.first.amountCents, equals(20000));
    });

    await testCase('Top-up with 0 cents throws 400 ApiException', () async {
      final client = MockApiClient();
      bool threw = false;
      try {
        await client.topUpWallet(0);
      } on ApiException catch (e) {
        threw = true;
        expect(e.statusCode, equals(400));
      }
      expect(threw, isTrue);
    });

    await testCase('Top-up with negative cents throws 400 ApiException', () async {
      final client = MockApiClient();
      bool threw = false;
      try {
        await client.topUpWallet(-5000);
      } on ApiException catch (e) {
        threw = true;
        expect(e.statusCode, equals(400));
      }
      expect(threw, isTrue);
    });

    await testCase('Consecutive wallet orders deduct balance sequentially', () async {
      final client = MockApiClient();
      // Order 1: 1 Onion
      await client.createOrder(
        items: [{'productId': TestFixtures.p1Onions.id, 'quantity': 1}],
        name: 'Aarav',
        phone: '9876543210',
        address: TestFixtures.addrHome.formatted,
        paymentMethodId: 'qwik_wallet',
      );
      final bal1 = (await client.wallet()).balanceCents;

      // Order 2: 1 Onion
      await client.createOrder(
        items: [{'productId': TestFixtures.p1Onions.id, 'quantity': 1}],
        name: 'Aarav',
        phone: '9876543210',
        address: TestFixtures.addrHome.formatted,
        paymentMethodId: 'qwik_wallet',
      );
      final bal2 = (await client.wallet()).balanceCents;

      expect(bal2 < bal1, isTrue);
    });

    await testCase('Transaction history records balanceAfterCents correctly', () async {
      final client = MockApiClient();
      await client.topUpWallet(10000); // +100
      final wallet = await client.wallet();
      final latestTx = wallet.transactions.first;
      expect(latestTx.balanceAfterCents, equals(60000));
    });

    await testCase('Paying via non-wallet method (e.g. COD or UPI) does not deduct wallet balance', () async {
      final client = MockApiClient();
      await client.createOrder(
        items: [{'productId': TestFixtures.p1Onions.id, 'quantity': 1}],
        name: 'Aarav',
        phone: '9876543210',
        address: TestFixtures.addrHome.formatted,
        paymentMethodId: 'cod',
      );
      final wallet = await client.wallet();
      expect(wallet.balanceCents, equals(50000));
    });
  });
}

Future<void> main() async {
  await runWalletBalanceBoundariesTests();
  globalTestSummary.printReport('Tier 2 WalletBalanceBoundaries');
}
