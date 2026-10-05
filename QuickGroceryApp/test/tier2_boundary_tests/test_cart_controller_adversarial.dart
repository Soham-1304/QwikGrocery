import 'package:qwik_grocery_app/models/product.dart';
import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_fixtures.dart';

Future<void> runCartControllerAdversarialTests() async {
  await testGroup('Adversarial 1: Delivery Threshold Precision (₹198.99 vs ₹199.00 vs ₹199.01)', () async {
    const item19899 = Product(
      id: 'p_198_99',
      name: 'Sub-threshold Item',
      category: 'Test',
      priceCents: 19899, // ₹198.99
      imageUrl: '',
      description: '',
      stock: 10,
    );

    const item19900 = Product(
      id: 'p_199_00',
      name: 'Exact Threshold Item',
      category: 'Test',
      priceCents: 19900, // ₹199.00
      imageUrl: '',
      description: '',
      stock: 10,
    );

    const item19901 = Product(
      id: 'p_199_01',
      name: 'Super-threshold Item',
      category: 'Test',
      priceCents: 19901, // ₹199.01
      imageUrl: '',
      description: '',
      stock: 10,
    );

    const item002 = Product(
      id: 'p_0_02',
      name: '2 Paisa Item',
      category: 'Test',
      priceCents: 2, // ₹0.02
      imageUrl: '',
      description: '',
      stock: 10,
    );

    await testCase('Subtotal ₹198.99 (1 paisa below threshold): free delivery is false, fee is ₹25', () {
      final cart = CartController();
      cart.add(item19899, quantity: 1);
      expect((cart.subtotal - 198.99).abs() < 0.001, isTrue);
      expect(cart.hasFreeDelivery, isFalse);
      expect(cart.deliveryFee, equals(25.0));
      expect((cart.amountNeededForFreeDelivery - 0.01).abs() < 0.001, isTrue);
      expect(cart.freeDeliveryProgress < 1.0, isTrue);
      // Total = 198.99 + 25.0 + 10.0 + (198.99 * 0.05 = 9.9495) = 243.9395
      final expectedTotal = 198.99 + 25.0 + 10.0 + (198.99 * 0.05);
      expect((cart.total - expectedTotal).abs() < 0.001, isTrue);
    });

    await testCase('Subtotal ₹199.00 (exact threshold): free delivery is true, fee is ₹0', () {
      final cart = CartController();
      cart.add(item19900, quantity: 1);
      expect(cart.subtotal, equals(199.0));
      expect(cart.hasFreeDelivery, isTrue);
      expect(cart.deliveryFee, equals(0.0));
      expect(cart.amountNeededForFreeDelivery, equals(0.0));
      expect(cart.freeDeliveryProgress, equals(1.0));
      // Total = 199.0 + 0.0 + 10.0 + (199.0 * 0.05 = 9.95) = 218.95
      final expectedTotal = 199.0 + 0.0 + 10.0 + 9.95;
      expect((cart.total - expectedTotal).abs() < 0.001, isTrue);
    });

    await testCase('Subtotal ₹199.01 (1 paisa above threshold): free delivery is true, fee is ₹0', () {
      final cart = CartController();
      cart.add(item19901, quantity: 1);
      expect((cart.subtotal - 199.01).abs() < 0.001, isTrue);
      expect(cart.hasFreeDelivery, isTrue);
      expect(cart.deliveryFee, equals(0.0));
      expect(cart.amountNeededForFreeDelivery, equals(0.0));
      expect(cart.freeDeliveryProgress, equals(1.0));
    });

    await testCase('Crossing from ₹198.99 to ₹199.01 by adding 2 paise item unlocks free delivery', () {
      final cart = CartController();
      cart.add(item19899, quantity: 1);
      expect(cart.hasFreeDelivery, isFalse);
      expect(cart.deliveryFee, equals(25.0));

      cart.add(item002, quantity: 1);
      // 198.99 + 0.02 = 199.01
      expect((cart.subtotal - 199.01).abs() < 0.001, isTrue);
      expect(cart.hasFreeDelivery, isTrue);
      expect(cart.deliveryFee, equals(0.0));
    });

    await testCase('Multi-item decomposition summing exactly to 19900 cents triggers free delivery', () {
      final cart = CartController();
      // 3 items with prices 6633, 6633, 6634 cents = 19900 cents = ₹199.00
      const pA = Product(id: 'pa', name: 'A', category: 'T', priceCents: 6633, imageUrl: '', description: '', stock: 5);
      const pB = Product(id: 'pb', name: 'B', category: 'T', priceCents: 6633, imageUrl: '', description: '', stock: 5);
      const pC = Product(id: 'pc', name: 'C', category: 'T', priceCents: 6634, imageUrl: '', description: '', stock: 5);

      cart.add(pA);
      cart.add(pB);
      cart.add(pC);

      expect((cart.subtotal - 199.0).abs() < 0.0001, isTrue);
      expect(cart.hasFreeDelivery, isTrue);
      expect(cart.deliveryFee, equals(0.0));
    });
  });

  await testGroup('Adversarial 2: Rapid Mutation Cycles & Invariant Verification', () async {
    void verifyCartInvariants(CartController cart) {
      expect(cart.itemCount, equals(cart.items.length));
      final calculatedQty = cart.items.values.fold(0, (s, i) => s + i.quantity);
      expect(cart.totalQuantity, equals(calculatedQty));
      expect(cart.count, equals(calculatedQty));

      final calculatedSubtotal = cart.items.values.fold(0.0, (s, i) => s + i.lineTotal);
      expect((cart.subtotal - calculatedSubtotal).abs() < 0.0001, isTrue);

      for (final item in cart.items.values) {
        expect(item.quantity > 0, isTrue);
        expect(item.quantity <= item.product.stock, isTrue);
      }

      if (cart.items.isEmpty) {
        expect(cart.subtotal, equals(0.0));
        expect(cart.total, equals(0.0));
        expect(cart.deliveryFee, equals(0.0));
        expect(cart.packagingCharge, equals(0.0));
        expect(cart.taxes, equals(0.0));
        expect(cart.hasFreeDelivery, isFalse);
      } else {
        expect(cart.hasFreeDelivery, equals(cart.subtotal >= 199.0));
        final expectedDel = cart.hasFreeDelivery ? 0.0 : 25.0;
        expect(cart.deliveryFee, equals(expectedDel));
        expect(cart.packagingCharge, equals(10.0));
        final expectedTotal = cart.subtotal + cart.deliveryFee + cart.packagingCharge + cart.taxes;
        expect((cart.total - expectedTotal).abs() < 0.001, isTrue);
      }
    }

    await testCase('Rapid 100-cycle alternating mutation loop maintains all invariants', () {
      final cart = CartController();
      final products = [
        TestFixtures.p1Onions,
        TestFixtures.p2Potatoes,
        TestFixtures.p3Tomatoes,
        TestFixtures.p4Milk,
        TestFixtures.p10Chips,
      ];

      for (int i = 0; i < 100; i++) {
        final prod = products[i % products.length];
        switch (i % 6) {
          case 0:
            cart.add(prod, quantity: (i % 3) + 1);
            break;
          case 1:
            cart.increment(prod);
            break;
          case 2:
            cart.decrement(prod.id);
            break;
          case 3:
            cart.setQuantity(prod.id, (i % 4));
            break;
          case 4:
            cart.remove(prod.id);
            break;
          case 5:
            if (i % 20 == 5) cart.clear();
            break;
        }
        verifyCartInvariants(cart);
      }
    });

    await testCase('Complete clear() after heavy state resets all fields cleanly to 0', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 5);
      cart.add(TestFixtures.p4Milk, quantity: 4);
      cart.add(TestFixtures.p7Atta, quantity: 2);
      expect(cart.itemCount, equals(3));
      expect(cart.totalQuantity, equals(11));

      cart.clear();
      expect(cart.itemCount, equals(0));
      expect(cart.totalQuantity, equals(0));
      expect(cart.count, equals(0));
      expect(cart.subtotal, equals(0.0));
      expect(cart.mrpTotal, equals(0.0));
      expect(cart.mrpSavings, equals(0.0));
      expect(cart.deliveryFee, equals(0.0));
      expect(cart.packagingCharge, equals(0.0));
      expect(cart.taxes, equals(0.0));
      expect(cart.total, equals(0.0));
      expect(cart.hasFreeDelivery, isFalse);
    });
  });

  await testGroup('Adversarial 3: Non-Existent IDs, Zero, Negatives, & Stock Caps', () async {
    await testCase('decrement() on non-existent product ID is safe no-op with 0 listener calls', () {
      final cart = CartController();
      int notifyCount = 0;
      cart.addListener(() => notifyCount++);
      cart.decrement('non_existent_sku');
      expect(cart.itemCount, equals(0));
      expect(notifyCount, equals(0));
    });

    await testCase('setQuantity() on non-existent product ID is safe no-op with 0 listener calls', () {
      final cart = CartController();
      int notifyCount = 0;
      cart.addListener(() => notifyCount++);
      cart.setQuantity('non_existent_sku', 10);
      expect(cart.itemCount, equals(0));
      expect(notifyCount, equals(0));
    });

    await testCase('remove() on non-existent product ID is safe no-op with 0 listener calls', () {
      final cart = CartController();
      int notifyCount = 0;
      cart.addListener(() => notifyCount++);
      cart.remove('non_existent_sku');
      expect(cart.itemCount, equals(0));
      expect(notifyCount, equals(0));
    });

    await testCase('add() with quantity 0 or negative is safe no-op with 0 listener calls', () {
      final cart = CartController();
      int notifyCount = 0;
      cart.addListener(() => notifyCount++);
      cart.add(TestFixtures.p1Onions, quantity: 0);
      cart.add(TestFixtures.p1Onions, quantity: -1);
      cart.add(TestFixtures.p1Onions, quantity: -100);
      expect(cart.itemCount, equals(0));
      expect(notifyCount, equals(0));
    });

    await testCase('add() for out-of-stock product (stock = 0) is safe no-op with 0 listener calls', () {
      final cart = CartController();
      int notifyCount = 0;
      cart.addListener(() => notifyCount++);
      cart.add(TestFixtures.p14OutOfStock, quantity: 1);
      expect(cart.itemCount, equals(0));
      expect(notifyCount, equals(0));
    });

    await testCase('add() clamps quantity strictly to available stock', () {
      final cart = CartController();
      // p15CappedStock has stock = 2
      cart.add(TestFixtures.p15CappedStock, quantity: 100);
      expect(cart.quantityOf(TestFixtures.p15CappedStock.id), equals(2));
      expect(cart.totalQuantity, equals(2));

      // Attempting to increment further stays clamped at stock 2
      cart.increment(TestFixtures.p15CappedStock);
      expect(cart.quantityOf(TestFixtures.p15CappedStock.id), equals(2));
    });

    await testCase('setQuantity() clamps quantity strictly to available stock', () {
      final cart = CartController();
      cart.add(TestFixtures.p15CappedStock, quantity: 1);
      cart.setQuantity(TestFixtures.p15CappedStock.id, 50);
      expect(cart.quantityOf(TestFixtures.p15CappedStock.id), equals(2));
    });

    await testCase('setQuantity() with 0 or negative removes the item and notifies', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 3);
      int notifyCount = 0;
      cart.addListener(() => notifyCount++);

      cart.setQuantity(TestFixtures.p1Onions.id, 0);
      expect(cart.itemCount, equals(0));
      expect(notifyCount, equals(1));

      cart.add(TestFixtures.p1Onions, quantity: 3);
      cart.setQuantity(TestFixtures.p1Onions.id, -5);
      expect(cart.itemCount, equals(0));
    });
  });

  await testGroup('Adversarial 4: Encapsulation & Immutable Snapshot Integrity', () async {
    await testCase('cart.items unmodifiable map prevents direct tampering', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 1);
      bool threw = false;
      try {
        cart.items['hack'] = cart.items[TestFixtures.p1Onions.id]!;
      } catch (e) {
        threw = true;
      }
      expect(threw, isTrue);
    });

    await testCase('cart.itemsList unmodifiable list prevents direct tampering', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 1);
      bool threw = false;
      try {
        cart.itemsList.add(cart.items[TestFixtures.p1Onions.id]!);
      } catch (e) {
        threw = true;
      }
      expect(threw, isTrue);
    });

    await testCase('toBillSummary() produces consistent snapshot matching controller getters', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2);
      cart.add(TestFixtures.p4Milk, quantity: 1);
      final bill = cart.toBillSummary();

      expect(bill.itemTotal, equals(cart.subtotal));
      expect(bill.mrpTotal, equals(cart.mrpTotal));
      expect(bill.mrpSavings, equals(cart.mrpSavings));
      expect(bill.deliveryFee, equals(cart.deliveryFee));
      expect(bill.packagingCharge, equals(cart.packagingCharge));
      expect(bill.taxes, equals(cart.taxes));
      expect(bill.total, equals(cart.total));
      expect(bill.freeDeliveryThreshold, equals(cart.freeDeliveryThreshold));
      expect(bill.amountNeededForFreeDelivery, equals(cart.amountNeededForFreeDelivery));
    });

    await testCase('BillSummary snapshot remains immutable when cart changes afterwards', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 1);
      final billSnapshot = cart.toBillSummary();
      final originalTotal = billSnapshot.total;

      // Mutate cart
      cart.add(TestFixtures.p7Atta, quantity: 3);
      expect(cart.total > originalTotal, isTrue);
      // Snapshot is unchanged
      expect(billSnapshot.total, equals(originalTotal));
    });
  });

  await testGroup('Adversarial 5: Notification Contracts & Redundant Call Elimination', () async {
    await testCase('Calling clear() on empty cart produces 0 notifications', () {
      final cart = CartController();
      int notifyCount = 0;
      cart.addListener(() => notifyCount++);
      cart.clear();
      expect(notifyCount, equals(0));
    });

    await testCase('Calling clear() on populated cart produces exactly 1 notification', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 1);
      cart.add(TestFixtures.p2Potatoes, quantity: 2);

      int notifyCount = 0;
      cart.addListener(() => notifyCount++);
      cart.clear();
      expect(notifyCount, equals(1));
    });

    await testCase('Calling remove() on existing item produces exactly 1 notification', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 1);

      int notifyCount = 0;
      cart.addListener(() => notifyCount++);
      cart.remove(TestFixtures.p1Onions.id);
      expect(notifyCount, equals(1));
    });
  });
}

Future<void> main() async {
  await runCartControllerAdversarialTests();
  globalTestSummary.printReport('Tier 2 CartController Adversarial Suite');
}
