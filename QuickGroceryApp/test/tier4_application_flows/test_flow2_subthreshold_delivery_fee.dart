import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_fixtures.dart';

Future<void> runFlow2SubthresholdDeliveryFeeTests() async {
  await testGroup('Tier 4 Flow 2: Sub-threshold Delivery Fee & Dynamic Free Delivery Unlock', () async {
    await testCase('Small order (Milk ₹68) triggers deficit and ₹25 delivery fee', () {
      final cart = CartController();
      cart.add(TestFixtures.p4Milk, quantity: 1); // 68.0

      expect(cart.subtotal, equals(68.0));
      expect(cart.hasFreeDelivery, isFalse);
      expect(cart.deliveryFee, equals(25.0));
      expect(cart.amountNeededForFreeDelivery, equals(131.0)); // 199 - 68
      expect(cart.freeDeliveryProgress < 1.0, isTrue);

      final bill = cart.toBillSummary();
      expect(bill.deliveryFee, equals(25.0));
      expect(bill.total, equals(68.0 + 25.0 + 10.0 + (68.0 * 0.05)));
    });

    await testCase('Adding items updates deficit meter incrementally', () {
      final cart = CartController();
      cart.add(TestFixtures.p4Milk, quantity: 1); // 68.0
      expect(cart.amountNeededForFreeDelivery, equals(131.0));

      // User adds Curd (35.0) -> subtotal = 103.0
      cart.add(TestFixtures.p5Curd, quantity: 1);
      expect(cart.subtotal, equals(103.0));
      expect(cart.amountNeededForFreeDelivery, equals(96.0)); // 199 - 103

      // User adds Butter (58.0) -> subtotal = 161.0
      cart.add(TestFixtures.p6Butter, quantity: 1);
      expect(cart.subtotal, equals(161.0));
      expect(cart.amountNeededForFreeDelivery, equals(38.0)); // 199 - 161
      expect(cart.hasFreeDelivery, isFalse);
      expect(cart.deliveryFee, equals(25.0));
    });

    await testCase('Adding Juice (₹80) crosses ₹199 threshold and unlocks FREE delivery', () {
      final cart = CartController();
      cart.add(TestFixtures.p4Milk, quantity: 1);   // 68
      cart.add(TestFixtures.p5Curd, quantity: 1);   // 35
      cart.add(TestFixtures.p6Butter, quantity: 1); // 58
      // Subtotal = 161.0

      // User adds Orange Juice (80.0) -> subtotal becomes 241.0 >= 199.0
      cart.add(TestFixtures.p12Juice, quantity: 1);
      expect(cart.subtotal, equals(241.0));
      expect(cart.hasFreeDelivery, isTrue);
      expect(cart.deliveryFee, equals(0.0));
      expect(cart.amountNeededForFreeDelivery, equals(0.0));
      expect(cart.freeDeliveryProgress, equals(1.0));

      final finalBill = cart.toBillSummary();
      expect(finalBill.deliveryFee, equals(0.0));
      expect(finalBill.hasFreeDelivery, isTrue);
    });
  });
}

Future<void> main() async {
  await runFlow2SubthresholdDeliveryFeeTests();
  globalTestSummary.printReport('Tier 4 Flow 2');
}
