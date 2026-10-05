import 'package:qwik_grocery_app/models/product.dart';
import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_fixtures.dart';

Future<void> runStockLimitCapsTests() async {
  await testGroup('Tier 2: Stock Limit Caps & Out-of-Stock Boundaries', () async {
    // Saffron has stock: 2
    final saffron = TestFixtures.p15CappedStock;
    // Berries has stock: 0
    final outOfStock = TestFixtures.p14OutOfStock;

    await testCase('Adding item up to exact available stock succeeds', () {
      final cart = CartController();
      cart.add(saffron, quantity: 2);
      expect(cart.quantityOf(saffron.id), equals(2));
      expect(cart.quantityOf(saffron.id), equals(saffron.stock));
    });

    await testCase('Adding beyond available stock clamps quantity to available stock', () {
      final cart = CartController();
      cart.add(saffron, quantity: 10); // Attempting to add 10 when stock is 2
      expect(cart.quantityOf(saffron.id), equals(2));
    });

    await testCase('increment() when already at stock limit does not increase quantity', () {
      final cart = CartController();
      cart.add(saffron, quantity: 2);
      cart.increment(saffron);
      expect(cart.quantityOf(saffron.id), equals(2));
    });

    await testCase('setQuantity() higher than stock clamps quantity to stock', () {
      final cart = CartController();
      cart.add(saffron, quantity: 1);
      cart.setQuantity(saffron.id, 99);
      expect(cart.quantityOf(saffron.id), equals(2));
    });

    await testCase('Product with stock 0 cannot be added to cart', () {
      final cart = CartController();
      cart.add(outOfStock, quantity: 1);
      expect(cart.itemCount, equals(0));
      expect(cart.quantityOf(outOfStock.id), equals(0));
    });

    await testCase('increment() on stock 0 product does not add it', () {
      final cart = CartController();
      cart.increment(outOfStock);
      expect(cart.itemCount, equals(0));
      expect(cart.quantityOf(outOfStock.id), equals(0));
    });

    await testCase('Single unit stock product caps at 1', () {
      final cart = CartController();
      const singleItem = Product(
        id: 'single_stock_item',
        name: 'Single Unit Item',
        category: 'Snacks',
        priceCents: 5000,
        imageUrl: '',
        description: '',
        stock: 1,
      );
      cart.add(singleItem, quantity: 1);
      expect(cart.quantityOf(singleItem.id), equals(1));
      cart.increment(singleItem);
      expect(cart.quantityOf(singleItem.id), equals(1));
    });

    await testCase('Subtotal and bill reflect strictly clamped quantities', () {
      final cart = CartController();
      // Price is 199.0
      cart.add(saffron, quantity: 50); // Clamped to 2 -> 398.0
      expect(cart.subtotal, equals(398.0));
      expect(cart.totalQuantity, equals(2));
    });

    await testCase('Stock clamping applies when adding incrementally', () {
      final cart = CartController();
      cart.add(saffron, quantity: 1);
      expect(cart.quantityOf(saffron.id), equals(1));
      cart.add(saffron, quantity: 1); // now 2
      expect(cart.quantityOf(saffron.id), equals(2));
      cart.add(saffron, quantity: 1); // attempt 3 -> clamped to 2
      expect(cart.quantityOf(saffron.id), equals(2));
    });

    await testCase('Stock check available property is false for stock <= 0', () {
      expect(outOfStock.available, isFalse);
      expect(outOfStock.stock <= 0, isTrue);
      expect(saffron.available, isTrue);
    });
  });
}

Future<void> main() async {
  await runStockLimitCapsTests();
  globalTestSummary.printReport('Tier 2 StockLimitCaps');
}
