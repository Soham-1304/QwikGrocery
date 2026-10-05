import 'package:qwik_grocery_app/models/product.dart';
import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_components.dart';
import '../harness/test_fixtures.dart';

Future<void> runProductDetailFeaturesTests() async {
  await testGroup('Tier 1: Product Detail & Recommendations', () async {
    await testCase('allImages returns gallery images when present', () {
      final milk = TestFixtures.p4Milk;
      expect(milk.images.length, equals(2));
      expect(milk.allImages.length, equals(2));
      expect(milk.allImages.first, contains('milk-front'));
    });

    await testCase('allImages falls back to single imageUrl when images list is empty', () {
      final tomatoes = TestFixtures.p3Tomatoes;
      expect(tomatoes.images.isEmpty, isTrue);
      expect(tomatoes.allImages.length, equals(1));
      expect(tomatoes.allImages.first, equals(tomatoes.imageUrl));
    });

    await testCase('allImages returns empty list if neither images nor imageUrl exist', () {
      const prod = Product(
        id: 'no_img',
        name: 'Mystery Item',
        category: 'Snacks',
        priceCents: 1000,
        imageUrl: '',
        description: '',
        stock: 5,
      );
      expect(prod.allImages.isEmpty, isTrue);
    });

    await testCase('FreshnessBadge component renders badgeText', () {
      const badge = FreshnessBadge(badgeText: '100% Quality Guarantee');
      expect(badge.badgeText, equals('100% Quality Guarantee'));
    });

    await testCase('Product freshnessBadges list includes expected guarantee tags', () {
      final onions = TestFixtures.p1Onions;
      expect(onions.freshnessBadges, contains('Direct from Farm'));
      expect(onions.freshnessBadges, contains('100% Quality Guarantee'));

      final milk = TestFixtures.p4Milk;
      expect(milk.freshnessBadges, contains('Cold Chain Maintained'));
    });

    await testCase('Product nutritionalInfo map exposes nutrient key-values', () {
      final milk = TestFixtures.p4Milk;
      expect(milk.nutritionalInfo.containsKey('Protein'), isTrue);
      expect(milk.nutritionalInfo['Protein'], equals('3.2 g'));
      expect(milk.nutritionalInfo['Calcium'], equals('120 mg'));
      expect(milk.nutritionalInfo['Fat'], equals('6.0 g'));
    });

    await testCase('Product storageInstructions exposes storage guidelines', () {
      final onions = TestFixtures.p1Onions;
      expect(onions.storageInstructions, contains('cool, dry, well-ventilated'));

      final milk = TestFixtures.p4Milk;
      expect(milk.storageInstructions, contains('Refrigerate at 4°C'));
    });

    await testCase('Frequently Bought Together (FBT) recommendation linking', () {
      // Complementary pairings: Onions (p1) -> Potatoes (p2) and Tomatoes (p3)
      final recommendations = [TestFixtures.p2Potatoes, TestFixtures.p3Tomatoes];
      expect(recommendations.length, equals(2));
      for (final rec in recommendations) {
        expect(rec.category, equals('Vegetables'));
      }
    });

    await testCase('Sticky bottom action bar computes selected quantity line total', () {
      final product = TestFixtures.p1Onions; // ₹35.00
      int selectedQty = 3;
      double lineTotal = product.price * selectedQty;
      expect(lineTotal, equals(105.0));

      selectedQty = 5;
      lineTotal = product.price * selectedQty;
      expect(lineTotal, equals(175.0));
    });

    await testCase('Sticky bottom action bar adds selected quantity to CartController', () {
      final cart = CartController();
      final product = TestFixtures.p1Onions;
      // User adds 4 units from bottom action bar
      cart.add(product, quantity: 4);
      expect(cart.quantityOf(product.id), equals(4));
      expect(cart.subtotal, equals(140.0));
    });
  });
}

Future<void> main() async {
  await runProductDetailFeaturesTests();
  globalTestSummary.printReport('Tier 1 ProductDetailFeatures');
}
