import 'package:qwik_grocery_app/models/product.dart';
import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/test_app_harness.dart';

Future<void> runFreeDeliveryExactThresholdTests() async {
  await testGroup('Tier 2: Exact Free Delivery Boundary (₹198 vs ₹199 vs ₹200)', () async {
    const item198 = Product(
      id: 'p_198',
      name: 'Item 198',
      category: 'Test',
      priceCents: 19800, // ₹198.00
      imageUrl: '',
      description: '',
      stock: 10,
    );

    const item1Cent = Product(
      id: 'p_1_cent',
      name: '1 Rupee Item',
      category: 'Test',
      priceCents: 100, // ₹1.00
      imageUrl: '',
      description: '',
      stock: 10,
    );

    const item199 = Product(
      id: 'p_199',
      name: 'Item 199',
      category: 'Test',
      priceCents: 19900, // ₹199.00
      imageUrl: '',
      description: '',
      stock: 10,
    );

    const item200 = Product(
      id: 'p_200',
      name: 'Item 200',
      category: 'Test',
      priceCents: 20000, // ₹200.00
      imageUrl: '',
      description: '',
      stock: 10,
    );

    await testCase('Subtotal ₹198.00 (₹1 below threshold): free delivery is false, fee is ₹25', () {
      final cart = CartController();
      cart.add(item198, quantity: 1);
      expect(cart.subtotal, equals(198.0));
      expect(cart.hasFreeDelivery, isFalse);
      expect(cart.deliveryFee, equals(25.0));
      expect(cart.amountNeededForFreeDelivery, equals(1.0));
      expect(cart.freeDeliveryProgress < 1.0, isTrue);
    });

    await testCase('Subtotal ₹199.00 (EXACT THRESHOLD): free delivery is true, fee is ₹0', () {
      final cart = CartController();
      cart.add(item199, quantity: 1);
      expect(cart.subtotal, equals(199.0));
      expect(cart.hasFreeDelivery, isTrue);
      expect(cart.deliveryFee, equals(0.0));
      expect(cart.amountNeededForFreeDelivery, equals(0.0));
      expect(cart.freeDeliveryProgress, equals(1.0));
    });

    await testCase('Subtotal ₹200.00 (₹1 above threshold): free delivery is true, fee is ₹0', () {
      final cart = CartController();
      cart.add(item200, quantity: 1);
      expect(cart.subtotal, equals(200.0));
      expect(cart.hasFreeDelivery, isTrue);
      expect(cart.deliveryFee, equals(0.0));
      expect(cart.amountNeededForFreeDelivery, equals(0.0));
      expect(cart.freeDeliveryProgress, equals(1.0));
    });

    await testCase('Crossing from ₹198 to ₹199 by adding ₹1 item removes delivery fee', () {
      final cart = CartController();
      cart.add(item198, quantity: 1);
      expect(cart.deliveryFee, equals(25.0));
      cart.add(item1Cent, quantity: 1); // subtotal becomes 199.0
      expect(cart.subtotal, equals(199.0));
      expect(cart.hasFreeDelivery, isTrue);
      expect(cart.deliveryFee, equals(0.0));
    });

    await testCase('Dropping from ₹199 to ₹198 by removing ₹1 item restores ₹25 delivery fee', () {
      final cart = CartController();
      cart.add(item198, quantity: 1);
      cart.add(item1Cent, quantity: 1);
      expect(cart.hasFreeDelivery, isTrue);
      cart.remove(item1Cent.id);
      expect(cart.subtotal, equals(198.0));
      expect(cart.hasFreeDelivery, isFalse);
      expect(cart.deliveryFee, equals(25.0));
    });

    await testCase('Subtotal ₹500 (well above threshold) clamps progress strictly at 1.0', () {
      final cart = CartController();
      cart.add(item200, quantity: 3); // 600.0
      expect(cart.subtotal, equals(600.0));
      expect(cart.hasFreeDelivery, isTrue);
      expect(cart.freeDeliveryProgress, equals(1.0));
      expect(cart.amountNeededForFreeDelivery, equals(0.0));
    });

    await testCase('Net payable total comparison: ₹198 subtotal vs ₹199 subtotal', () {
      // At ₹198: 198 + 25 (del) + 10 (pack) + 9.90 (tax 5%) = 242.90
      final cart198 = CartController();
      cart198.add(item198);
      final total198 = cart198.total;

      // At ₹199: 199 + 0 (del) + 10 (pack) + 9.95 (tax 5%) = 218.95
      final cart199 = CartController();
      cart199.add(item199);
      final total199 = cart199.total;

      // Notice that buying ₹199 item is actually CHEAPER than ₹198 due to free delivery!
      expect(total199 < total198, isTrue);
      expect((total198 - total199) > 20.0, isTrue);
    });

    await testCase('freeDeliveryProgress mathematical fraction at ₹198', () {
      final cart = CartController();
      cart.add(item198);
      final expected = 198.0 / 199.0;
      expect((cart.freeDeliveryProgress - expected).abs() < 0.0001, isTrue);
    });

    await testCase('Progress never goes below 0.0 or above 1.0', () {
      final cart = CartController();
      expect(cart.freeDeliveryProgress >= 0.0, isTrue);
      cart.add(item200, quantity: 10);
      expect(cart.freeDeliveryProgress <= 1.0, isTrue);
    });

    await testCase('Threshold constant is exactly ₹199.0', () {
      final cart = CartController();
      expect(cart.freeDeliveryThreshold, equals(199.0));
    });
  });
}

Future<void> main() async {
  await runFreeDeliveryExactThresholdTests();
  globalTestSummary.printReport('Tier 2 FreeDeliveryExactThreshold');
}
