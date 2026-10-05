import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_components.dart';
import '../harness/test_fixtures.dart';

Future<void> runDeliveryMeterTests() async {
  await testGroup('Tier 1: Free Delivery Progress Meter', () async {
    await testCase('Shows deficit message when cart subtotal is under ₹199', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2); // 70.0
      expect(cart.hasFreeDelivery, isFalse);
      expect(cart.amountNeededForFreeDelivery, equals(129.0));

      final meter = DeliveryMeter(controller: cart);
      expect(meter.compact, isFalse);
    });

    await testCase('Computes exact progress fraction between 0.0 and 1.0', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2); // 70.0
      // 70 / 199 = ~0.3517
      final expectedProgress = 70.0 / 199.0;
      expect((cart.freeDeliveryProgress - expectedProgress).abs() < 0.001, isTrue);
    });

    await testCase('Shows unlocked status and caps progress at 1.0 when threshold is reached', () {
      final cart = CartController();
      cart.add(TestFixtures.p7Atta, quantity: 1); // 260.0 >= 199.0
      expect(cart.hasFreeDelivery, isTrue);
      expect(cart.freeDeliveryProgress, equals(1.0));
      expect(cart.amountNeededForFreeDelivery, equals(0.0));
    });

    await testCase('Handles empty cart with 0 progress and ₹199 deficit', () {
      final cart = CartController();
      expect(cart.subtotal, equals(0.0));
      expect(cart.freeDeliveryProgress, equals(0.0));
      expect(cart.amountNeededForFreeDelivery, equals(199.0));
      expect(cart.hasFreeDelivery, isFalse);
    });

    await testCase('Updates progress reactively when items are incremented', () {
      final cart = CartController();
      cart.add(TestFixtures.p4Milk, quantity: 1); // 68.0
      final progress1 = cart.freeDeliveryProgress;
      cart.increment(TestFixtures.p4Milk); // 136.0
      final progress2 = cart.freeDeliveryProgress;
      expect(progress2, greaterThan(progress1));
    });

    await testCase('Unlocks when crossing exactly ₹199.0', () {
      final cart = CartController();
      cart.add(TestFixtures.p15CappedStock, quantity: 1); // exactly 199.0
      expect(cart.subtotal, equals(199.0));
      expect(cart.hasFreeDelivery, isTrue);
      expect(cart.freeDeliveryProgress, equals(1.0));
    });

    await testCase('DeliveryMeter instantiation with compact flag', () {
      final meterCompact = const DeliveryMeter(compact: true);
      expect(meterCompact.compact, isTrue);
      final meterNormal = const DeliveryMeter(compact: false);
      expect(meterNormal.compact, isFalse);
    });

    await testCase('Exceeding threshold (e.g. ₹500) clamps progress strictly at 1.0', () {
      final cart = CartController();
      cart.add(TestFixtures.p7Atta, quantity: 2); // 520.0
      expect(cart.subtotal, equals(520.0));
      expect(cart.freeDeliveryProgress, equals(1.0));
      expect(cart.deliveryFee, equals(0.0));
    });
  });
}

Future<void> main() async {
  await runDeliveryMeterTests();
  globalTestSummary.printReport('Tier 1 DeliveryMeter');
}
