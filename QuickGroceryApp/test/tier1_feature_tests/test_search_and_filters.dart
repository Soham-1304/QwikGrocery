import '../harness/mock_api_client.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_fixtures.dart';

Future<void> runSearchAndFiltersTests() async {
  await testGroup('Tier 1: Sticky Search & Instant Filtering', () async {
    final client = MockApiClient();

    await testCase('Search matches product name case-insensitively', () async {
      final results = await client.products(search: 'onions');
      expect(results.length, equals(1));
      expect(results.first.name, equals('Farm Fresh Onions'));

      final resultsCaps = await client.products(search: 'ONIONS');
      expect(resultsCaps.length, equals(1));
      expect(resultsCaps.first.id, equals('prod_onions'));
    });

    await testCase('Search matches brand name', () async {
      final results = await client.products(search: 'AMUL');
      expect(results.length, equals(2)); // Milk & Butter
      final brands = results.map((p) => p.brand).toSet();
      expect(brands.contains('AMUL'), isTrue);
    });

    await testCase('Search matches Hindi / regional aliases', () async {
      // "pyaz" -> Farm Fresh Onions
      final onions = await client.products(search: 'pyaz');
      expect(onions.length, equals(1));
      expect(onions.first.id, equals('prod_onions'));

      // "doodh" -> Full Cream Fresh Milk
      final milk = await client.products(search: 'doodh');
      expect(milk.length, equals(1));
      expect(milk.first.id, equals('prod_milk'));

      // "aloo" -> Organic Potatoes
      final potatoes = await client.products(search: 'aloo');
      expect(potatoes.length, equals(1));
      expect(potatoes.first.id, equals('prod_potatoes'));
    });

    await testCase('Category filter restricts catalog to target category', () async {
      final veggies = await client.products(category: 'Vegetables');
      expect(veggies.length, equals(4)); // Onions, Potatoes, Tomatoes, Berries
      for (final p in veggies) {
        expect(p.category, equals('Vegetables'));
      }

      final dairy = await client.products(category: 'Dairy & Breakfast');
      expect(dairy.length, equals(3)); // Milk, Curd, Butter
    });

    await testCase('Category "All" returns complete catalog', () async {
      final all = await client.products(category: 'All');
      expect(all.length, equals(TestFixtures.allProducts.length));
    });

    await testCase('Available filter filters out out-of-stock items', () async {
      final availableOnly = await client.products(available: true);
      expect(availableOnly.any((p) => p.id == 'prod_berries'), isFalse);
      for (final p in availableOnly) {
        expect(p.stock, greaterThan(0));
      }

      final outOfStockOnly = await client.products(available: false);
      expect(outOfStockOnly.length, equals(1));
      expect(outOfStockOnly.first.id, equals('prod_berries'));
    });

    await testCase('Combined search and category filters apply conjunctively', () async {
      // Searching "fresh" in "Dairy & Breakfast"
      final results = await client.products(search: 'fresh', category: 'Dairy & Breakfast');
      expect(results.length, equals(2)); // Fresh Milk, Fresh Curd
      for (final p in results) {
        expect(p.category, equals('Dairy & Breakfast'));
        expect(p.name.toLowerCase().contains('fresh'), isTrue);
      }
    });

    await testCase('Empty search query preserves full category listing', () async {
      final results = await client.products(search: '', category: 'Snacks & Munchies');
      expect(results.length, equals(2)); // Chips, Almonds
    });

    await testCase('Sorting catalog by Price: Low to High', () async {
      final items = await client.products();
      final sorted = List.of(items)..sort((a, b) => a.priceCents.compareTo(b.priceCents));
      expect(sorted.first.priceCents, equals(2000)); // Lays Chips (₹20)
      for (int i = 0; i < sorted.length - 1; i++) {
        expect(sorted[i].priceCents <= sorted[i + 1].priceCents, isTrue);
      }
    });

    await testCase('Sorting catalog by Discount percentage: High to Low', () async {
      final items = await client.products();
      final sorted = List.of(items)..sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
      expect(sorted.first.discountPercentage, greaterThanOrEqualTo(sorted[1].discountPercentage));
      expect(sorted.first.discountPercentage, equals(30)); // Onions (30% OFF)
    });
  });
}

Future<void> main() async {
  await runSearchAndFiltersTests();
  globalTestSummary.printReport('Tier 1 Search & Filters');
}
