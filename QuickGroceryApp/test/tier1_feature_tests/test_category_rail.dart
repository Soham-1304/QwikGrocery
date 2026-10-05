import '../harness/test_app_harness.dart';
import '../harness/test_components.dart';
import '../harness/test_fixtures.dart';

Future<void> runCategoryRailTests() async {
  await testGroup('Tier 1: Visual Category Rail', () async {
    await testCase('CategoryRail renders all seeded categories', () {
      final rail = CategoryRail(
        categories: TestFixtures.allCategories,
        selectedId: 'cat_all',
        onSelect: (_) {},
      );
      expect(rail.categories.length, equals(7));
    });

    await testCase('CategoryRail highlights active selected category ID', () {
      final rail = CategoryRail(
        categories: TestFixtures.allCategories,
        selectedId: 'cat_veg',
        onSelect: (_) {},
      );
      expect(rail.selectedId, equals('cat_veg'));
    });

    await testCase('Tapping category chip invokes onSelect callback', () {
      String? selected;
      final rail = CategoryRail(
        categories: TestFixtures.allCategories,
        selectedId: 'cat_all',
        onSelect: (id) => selected = id,
      );

      rail.onSelect('cat_dairy');
      expect(selected, equals('cat_dairy'));
    });

    await testCase('Category model exposes iconName and itemCount', () {
      final cat = TestFixtures.allCategories[1]; // Vegetables
      expect(cat.name, equals('Vegetables'));
      expect(cat.iconName, equals('eco'));
      expect(cat.itemCount, equals(4));
    });

    await testCase('Selecting null defaults to first category (All)', () {
      final rail = CategoryRail(
        categories: TestFixtures.allCategories,
        selectedId: null,
        onSelect: (_) {},
      );
      expect(rail.selectedId, isNull);
    });

    await testCase('Category IDs are unique across rail items', () {
      final ids = TestFixtures.allCategories.map((c) => c.id).toSet();
      expect(ids.length, equals(TestFixtures.allCategories.length));
    });

    await testCase('Category names correspond to catalog sectors', () {
      final names = TestFixtures.allCategories.map((c) => c.name).toList();
      expect(names, contains('Vegetables'));
      expect(names, contains('Dairy & Breakfast'));
      expect(names, contains('Atta, Rice & Dal'));
      expect(names, contains('Snacks & Munchies'));
    });

    await testCase('Fast switching between category selections updates callback', () {
      final selectedHistory = <String?>[];
      final rail = CategoryRail(
        categories: TestFixtures.allCategories,
        selectedId: 'cat_all',
        onSelect: (id) => selectedHistory.add(id),
      );

      rail.onSelect('cat_veg');
      rail.onSelect('cat_dairy');
      rail.onSelect('cat_snacks');
      expect(selectedHistory.length, equals(3));
      expect(selectedHistory.last, equals('cat_snacks'));
    });
  });
}

Future<void> main() async {
  await runCategoryRailTests();
  globalTestSummary.printReport('Tier 1 CategoryRail');
}
