import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/mock_api_client.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_fixtures.dart';

Future<void> runFlow4DetailFbtAndBottomBarTests() async {
  await testGroup('Tier 4 Flow 4: Product Detail Deep-Dive & FBT Quick-Add Journey', () async {
    final client = MockApiClient();

    await testCase('User explores multi-image gallery, freshness badges, and nutrition info on Product Detail', () async {
      // User opens detail page for Full Cream Fresh Milk
      final milk = await client.product('prod_milk');
      expect(milk.allImages.length, equals(2));
      expect(milk.freshnessBadges, contains('Cold Chain Maintained'));
      expect(milk.nutritionalInfo['Protein'], equals('3.2 g'));
      expect(milk.storageInstructions, contains('Refrigerate'));
    });

    await testCase('User quick-adds Potatoes from FBT rail and uses sticky bottom bar to increment Onions', () async {
      final cart = CartController();

      // Step 1: User is on Onions detail page, adds 1 unit of Onions
      final onions = await client.product('prod_onions');
      cart.add(onions, quantity: 1);
      expect(cart.quantityOf(onions.id), equals(1));

      // Step 2: User taps Quick-Add on "Organic Potatoes" in Frequently Bought Together rail
      final potatoes = await client.product('prod_potatoes');
      cart.add(potatoes, quantity: 1);
      expect(cart.quantityOf(potatoes.id), equals(1));
      expect(cart.itemCount, equals(2));

      // Step 3: User uses sticky bottom bar to increase Onions to 3 units
      cart.setQuantity(onions.id, 3);
      expect(cart.quantityOf(onions.id), equals(3));

      // Total = Onions (35 * 3 = 105) + Potatoes (40 * 1 = 40) = 145.0
      expect(cart.subtotal, equals(145.0));
    });
  });
}

Future<void> main() async {
  await runFlow4DetailFbtAndBottomBarTests();
  globalTestSummary.printReport('Tier 4 Flow 4');
}
