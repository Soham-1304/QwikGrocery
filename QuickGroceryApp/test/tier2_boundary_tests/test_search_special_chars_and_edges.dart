import '../harness/mock_api_client.dart';
import '../harness/test_app_harness.dart';

Future<void> runSearchSpecialCharsAndEdgesTests() async {
  await testGroup('Tier 2: Search Special Chars & Boundary Inputs', () async {
    final client = MockApiClient();

    await testCase('Search with regex meta-characters does not crash or throw RegExp exception', () async {
      final results1 = await client.products(search: '.*');
      expect(results1 is List, isTrue);

      final results2 = await client.products(search: '[a-z]+');
      expect(results2 is List, isTrue);

      final results3 = await client.products(search: '(milk|curd)');
      expect(results3 is List, isTrue);

      final results4 = await client.products(search: r'^onions$');
      expect(results4 is List, isTrue);
    });

    await testCase('Search with special symbols returns empty list gracefully', () async {
      final results = await client.products(search: '!@#\$%^&*()');
      expect(results.isEmpty, isTrue);
    });

    await testCase('Search with leading and trailing whitespace is sanitized', () async {
      final results = await client.products(search: '   onions   ');
      expect(results.length, equals(1));
      expect(results.first.id, equals('prod_onions'));
    });

    await testCase('Search with only spaces returns full unfiltered catalog', () async {
      final results = await client.products(search: '    ');
      final all = await client.products();
      expect(results.length, equals(all.length));
    });

    await testCase('Search with very long string (500 characters) handles without hanging', () async {
      final longQuery = 'a' * 500;
      final results = await client.products(search: longQuery);
      expect(results.isEmpty, isTrue);
    });

    await testCase('Search with emojis or unicode symbols handles gracefully', () async {
      final results = await client.products(search: '🥛🍎🥦');
      expect(results.isEmpty, isTrue);
    });

    await testCase('Case insensitivity across mixed casing patterns', () async {
      final results1 = await client.products(search: 'oNiOnS');
      expect(results1.length, equals(1));

      final results2 = await client.products(search: 'aMuL');
      expect(results2.length, equals(2));
    });

    await testCase('Partial alias matching succeeds', () async {
      final results = await client.products(search: 'pya'); // prefix of "pyaz"
      expect(results.length, equals(1));
      expect(results.first.id, equals('prod_onions'));
    });

    await testCase('Search with nonexistent term yields empty results list', () async {
      final results = await client.products(search: 'supercalifragilistic123');
      expect(results.isEmpty, isTrue);
    });

    await testCase('Filtering with invalid non-existent category returns empty list', () async {
      final results = await client.products(category: 'NonExistentSpaceCategory');
      expect(results.isEmpty, isTrue);
    });
  });
}

Future<void> main() async {
  await runSearchSpecialCharsAndEdgesTests();
  globalTestSummary.printReport('Tier 2 SearchSpecialCharsAndEdges');
}
