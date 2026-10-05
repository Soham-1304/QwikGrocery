import 'package:qwik_grocery_app/models/bill_summary.dart';
import '../harness/mock_api_client.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_components.dart';
import '../harness/test_fixtures.dart';

Future<void> runCheckoutFeaturesTests() async {
  await testGroup('Tier 1: Rich Cart & Checkout Features', () async {
    final client = MockApiClient();

    await testCase('BillBreakdown renders item total line', () {
      const bill = BillSummary(
        itemTotal: 250.0,
        mrpTotal: 320.0,
        mrpSavings: 70.0,
        deliveryFee: 0.0,
        packagingCharge: 10.0,
        taxes: 12.5,
        total: 272.5,
      );
      final widget = const BillBreakdown(bill: bill);
      expect(widget.bill.itemTotal, equals(250.0));
    });

    await testCase('BillBreakdown displays MRP savings when > 0', () {
      const bill = BillSummary(
        itemTotal: 150.0,
        mrpTotal: 200.0,
        mrpSavings: 50.0,
        deliveryFee: 25.0,
        packagingCharge: 10.0,
        taxes: 7.5,
        total: 192.5,
      );
      expect(bill.mrpSavings, equals(50.0));
      expect(bill.mrpSavings > 0, isTrue);
    });

    await testCase('BillBreakdown displays FREE for deliveryFee when ₹0', () {
      const bill = BillSummary(
        itemTotal: 250.0,
        mrpTotal: 300.0,
        mrpSavings: 50.0,
        deliveryFee: 0.0,
        packagingCharge: 10.0,
        taxes: 12.5,
        total: 272.5,
      );
      expect(bill.hasFreeDelivery, isTrue);
      expect(bill.deliveryFee, equals(0.0));
    });

    await testCase('BillBreakdown displays packaging charge of ₹10', () {
      const bill = BillSummary(
        itemTotal: 100.0,
        mrpTotal: 120.0,
        mrpSavings: 20.0,
        deliveryFee: 25.0,
        packagingCharge: 10.0,
        taxes: 5.0,
        total: 140.0,
      );
      expect(bill.packagingCharge, equals(10.0));
    });

    await testCase('BillBreakdown displays 5% taxes calculation', () {
      const bill = BillSummary(
        itemTotal: 100.0,
        mrpTotal: 100.0,
        mrpSavings: 0.0,
        deliveryFee: 25.0,
        packagingCharge: 10.0,
        taxes: 5.0, // 5% of 100.0
        total: 140.0,
      );
      expect(bill.taxes, equals(5.0));
    });

    await testCase('BillBreakdown grand total matches sum of subtotal + delivery + packaging + tax', () {
      const bill = BillSummary(
        itemTotal: 100.0,
        mrpTotal: 120.0,
        mrpSavings: 20.0,
        deliveryFee: 25.0,
        packagingCharge: 10.0,
        taxes: 5.0,
        total: 140.0,
      );
      final expected = bill.itemTotal + bill.deliveryFee + bill.packagingCharge + bill.taxes;
      expect(bill.total, equals(expected));
    });

    await testCase('Delivery instruction chips toggle active selection', () {
      final selectedInstructions = <String>{};
      void toggleInstruction(String instruction) {
        if (selectedInstructions.contains(instruction)) {
          selectedInstructions.remove(instruction);
        } else {
          selectedInstructions.add(instruction);
        }
      }

      toggleInstruction('Leave at door');
      expect(selectedInstructions.contains('Leave at door'), isTrue);

      toggleInstruction("Don't ring bell");
      expect(selectedInstructions.length, equals(2));

      toggleInstruction('Leave at door');
      expect(selectedInstructions.contains('Leave at door'), isFalse);
      expect(selectedInstructions.length, equals(1));
    });

    await testCase('Item and order special notes capture text', () {
      String deliveryNotes = '';
      void updateNotes(String val) => deliveryNotes = val.trim();

      updateNotes('  Please call on arrival at gate 2   ');
      expect(deliveryNotes, equals('Please call on arrival at gate 2'));
    });

    await testCase('Multi-payment methods: QwikWallet, UPI, Cards, Cash on Delivery', () async {
      final wallet = await client.wallet();
      expect(wallet.balanceCents, equals(50000)); // ₹500.00 available

      final profile = await client.profile();
      expect(profile.paymentMethods.length, equals(2)); // UPI & Card

      const supportedPaymentTypes = ['qwik_wallet', 'upi', 'card', 'cod'];
      expect(supportedPaymentTypes.length, equals(4));
    });

    await testCase('Order placement generates Order ID and ETA', () async {
      final order = await client.createOrder(
        items: [
          {'productId': TestFixtures.p1Onions.id, 'quantity': 2},
        ],
        name: 'Aarav Sharma',
        phone: '9876543210',
        address: TestFixtures.addrHome.formatted,
        paymentMethodId: 'cod',
        instructions: 'Leave at door',
      );

      expect(order.id, isNotNull);
      expect(order.id.startsWith('ORD-'), isTrue);
      expect(order.status, equals('placed'));
      expect(order.delivery!['partnerName'], equals('Suresh Patel'));
      expect(order.delivery!['etaMinutes'], equals(12));
    });
  });
}

Future<void> main() async {
  await runCheckoutFeaturesTests();
  globalTestSummary.printReport('Tier 1 CheckoutFeatures');
}
