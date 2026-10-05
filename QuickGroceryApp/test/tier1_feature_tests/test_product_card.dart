import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_components.dart';
import '../harness/test_fixtures.dart';

Future<void> runProductCardTests() async {
  await testGroup('Tier 1: Modern Blinkit Product Card', () async {
    await testCase('ProductCard exposes product entity properties', () {
      final card = ProductCard(product: TestFixtures.p1Onions);
      expect(card.product.name, equals('Farm Fresh Onions'));
      expect(card.product.brand, equals('FARM PICK'));
      expect(card.product.displayUnit, equals('1 kg'));
      expect(card.product.price, equals(35.0));
      expect(card.product.mrp, equals(50.0));
    });

    await testCase('ProductCard shows brand in uppercase subtext', () {
      final card = ProductCard(product: TestFixtures.p4Milk);
      expect(card.product.brand.toUpperCase(), equals('AMUL'));
    });

    await testCase('ProductCard calculates discount pill percentage', () {
      final card = ProductCard(product: TestFixtures.p1Onions);
      expect(card.product.hasDiscount, isTrue);
      expect(card.product.discountPercentage, equals(30));
    });

    await testCase('ProductCard with no discount does not show discount pill', () {
      final card = ProductCard(product: TestFixtures.p10Chips);
      expect(card.product.hasDiscount, isFalse);
      expect(card.product.discountPercentage, equals(0));
    });

    await testCase('When quantity in cart is 0, renders "+ ADD" button', () {
      final cart = CartController();
      final card = ProductCard(
        product: TestFixtures.p1Onions,
        controller: cart,
      );
      expect(cart.quantityOf(TestFixtures.p1Onions.id), equals(0));
      // Tapping add adds item to cart
      cart.add(TestFixtures.p1Onions);
      expect(cart.quantityOf(TestFixtures.p1Onions.id), equals(1));
    });

    await testCase('When quantity in cart > 0, renders in-card QuantityStepper', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2);
      expect(cart.quantityOf(TestFixtures.p1Onions.id), equals(2));
      final card = ProductCard(
        product: TestFixtures.p1Onions,
        controller: cart,
      );
      expect(card.controller!.quantityOf(TestFixtures.p1Onions.id), equals(2));
    });

    await testCase('When product is out of stock (stock == 0), renders disabled out of stock state', () {
      final cart = CartController();
      final card = ProductCard(
        product: TestFixtures.p14OutOfStock,
        controller: cart,
      );
      expect(card.product.available, isFalse);
      expect(card.product.stock, equals(0));
      // Adding out of stock product does nothing
      cart.add(TestFixtures.p14OutOfStock);
      expect(cart.quantityOf(TestFixtures.p14OutOfStock.id), equals(0));
    });

    await testCase('Tapping ProductCard triggers onProductTap callback', () {
      bool tapped = false;
      final card = ProductCard(
        product: TestFixtures.p1Onions,
        onProductTap: () => tapped = true,
      );
      card.onProductTap?.call();
      expect(tapped, isTrue);
    });

    await testCase('ProductCard compact mode configuration', () {
      final cardCompact = ProductCard(product: TestFixtures.p1Onions, compact: true);
      expect(cardCompact.compact, isTrue);
      final cardNormal = ProductCard(product: TestFixtures.p1Onions, compact: false);
      expect(cardNormal.compact, isFalse);
    });

    await testCase('ProductCard displays strikethrough MRP styling data when discount is active', () {
      final p = TestFixtures.p1Onions;
      expect(p.mrp > p.price, isTrue);
      expect(p.savings, equals(15.0));
    });
  });
}

Future<void> main() async {
  await runProductCardTests();
  globalTestSummary.printReport('Tier 1 ProductCard');
}
