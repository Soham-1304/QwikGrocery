import '../harness/mock_api_client.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_components.dart';
import '../harness/test_fixtures.dart';

Future<void> runSearchCategoryRailSyncTests() async {
  await testGroup('Tier 3: Search Filtering <-> Category Rail Cross-Feature Interaction', () async {
    final client = MockApiClient();

    await testCase('Tapping category rail restricts instant search to target category', () async {
      String selectedCategory = 'Vegetables';
      final results = await client.products(search: 'fresh', category: selectedCategory);
      expect(results.isNotEmpty, isTrue);
      for (final p in results) {
        expect(p.category, equals('Vegetables'));
      }
    });

    await testCase('Clearing search input restores full category items without deselecting category', () async {
      const selectedCategory = 'Dairy & Breakfast';
      // Step 1: User searched "butter" in Dairy
      final searchResults = await client.products(search: 'butter', category: selectedCategory);
      expect(searchResults.length, equals(1));

      // Step 2: User taps clear button on search bar -> search = ''
      final clearedResults = await client.products(search: '', category: selectedCategory);
      expect(clearedResults.length, equals(3)); // Milk, Curd, Butter
      for (final p in clearedResults) {
        expect(p.category, equals('Dairy & Breakfast'));
      }
    });

    await testCase('In-stock toggle combined with category rail filters out out-of-stock items', () async {
      const selectedCategory = 'Vegetables';
      // In Vegetables, there are 4 items (Onions, Potatoes, Tomatoes, Berries). Berries has stock = 0.
      final allVeggies = await client.products(category: selectedCategory);
      expect(allVeggies.length, equals(4));

      // User toggles "In-Stock Only" chip
      final inStockVeggies = await client.products(category: selectedCategory, available: true);
      expect(inStockVeggies.length, equals(3));
      expect(inStockVeggies.any((p) => p.id == 'prod_berries'), isFalse);
    });

    await testCase('Category rail UI highlights active chip matching catalog filter', () {
      final rail = CategoryRail(
        categories: TestFixtures.allCategories,
        selectedId: 'cat_veg',
        onSelect: (_) {},
      );
      expect(rail.selectedId, equals('cat_veg'));
    });

    await testCase('Searching regional alias inside matching category succeeds', () async {
      // Searching "doodh" in "Dairy & Breakfast"
      final results = await client.products(search: 'doodh', category: 'Dairy & Breakfast');
      expect(results.length, equals(1));
      expect(results.first.id, equals('prod_milk'));
    });

    await testCase('Searching item from different category inside active category rail returns empty', () async {
      // Searching "doodh" (Milk - Dairy) while category is "Vegetables"
      final results = await client.products(search: 'doodh', category: 'Vegetables');
      expect(results.isEmpty, isTrue);
    });
  });
}

Future<void> main() async {
  await runSearchCategoryRailSyncTests();
  globalTestSummary.printReport('Tier 3 SearchCategoryRailSync');
}
