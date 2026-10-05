import 'dart:convert';
import 'dart:io';
import 'package:qwik_grocery_app/models/banner_item.dart';
import 'package:qwik_grocery_app/models/bill_summary.dart';
import 'package:qwik_grocery_app/models/cart_item.dart';
import 'package:qwik_grocery_app/models/category.dart';
import 'package:qwik_grocery_app/models/product.dart';
import '../harness/test_app_harness.dart';

Future<void> runAllChallengerVerificationTests() async {
  await testGroup('1. Enriched Models Serialization Round-Trip', () async {
    await testCase('Category serialization round-trip', () {
      const cat = Category(
        id: 'cat_dairy',
        name: 'Dairy & Breakfast',
        iconUrl: 'https://example.com/icon.png',
        iconName: 'egg',
        itemCount: 28,
      );
      final json = cat.toJson();
      final roundTrip = Category.fromJson(json);
      expect(roundTrip.id, equals(cat.id));
      expect(roundTrip.name, equals(cat.name));
      expect(roundTrip.itemCount, equals(28));
      expect(jsonEncode(roundTrip.toJson()), equals(jsonEncode(json)));
    });

    await testCase('BannerItem serialization round-trip', () {
      const banner = BannerItem(
        id: 'b1',
        title: 'Super Saver Deals',
        subtitle: 'Save up to 40% on groceries',
        imageUrl: 'https://example.com/b1.jpg',
        actionRoute: '/deals',
        categoryFilter: 'Produce',
        backgroundColorHex: '#1B5E20',
        badgeText: 'DEAL OF THE DAY',
      );
      final json = banner.toJson();
      final roundTrip = BannerItem.fromJson(json);
      expect(roundTrip.title, equals(banner.title));
      expect(roundTrip.badgeText, equals('DEAL OF THE DAY'));
      expect(roundTrip.categoryFilter, equals('Produce'));
      expect(jsonEncode(roundTrip.toJson()), equals(jsonEncode(json)));
    });

    await testCase('BillSummary serialization round-trip', () {
      const bill = BillSummary(
        itemTotal: 340.0,
        mrpTotal: 450.0,
        mrpSavings: 110.0,
        deliveryFee: 0.0,
        packagingCharge: 10.0,
        taxes: 17.0,
        total: 367.0,
        freeDeliveryThreshold: 199.0,
        amountNeededForFreeDelivery: 0.0,
      );
      final json = bill.toJson();
      final roundTrip = BillSummary.fromJson(json);
      expect(roundTrip.total, equals(367.0));
      expect(roundTrip.mrpSavings, equals(110.0));
      expect(roundTrip.hasFreeDelivery, isTrue);
      expect(jsonEncode(roundTrip.toJson()), equals(jsonEncode(json)));
    });

    await testCase('Product enriched fields serialization round-trip', () {
      const p = Product(
        id: 'p_spinach',
        name: 'Hydroponic Baby Spinach',
        category: 'Vegetables',
        priceCents: 4500,
        mrpCents: 6000,
        imageUrl: 'https://example.com/spinach1.jpg',
        images: ['https://example.com/spinach1.jpg', 'https://example.com/spinach2.jpg'],
        description: 'Fresh pesticide-free hydroponic spinach leaves',
        stock: 25,
        brand: 'URBAN GREENS',
        unit: '200 g pack',
        packUnit: '200 g punnet',
        aliases: ['palak', 'spinach', 'baby palak'],
        freshnessBadges: ['Pesticide Free', 'Harvested Today'],
        nutritionalInfo: {'Iron': '2.7mg', 'Vitamin A': '9377 IU'},
        storageInstructions: 'Keep refrigerated below 4°C',
        rating: 4.85,
        ratingCount: 154,
      );
      final json = p.toJson();
      final roundTrip = Product.fromJson(json);
      expect(roundTrip.id, equals(p.id));
      expect(roundTrip.name, equals(p.name));
      expect(roundTrip.brand, equals('URBAN GREENS'));
      expect(roundTrip.discountPercentage, equals(25));
      expect(roundTrip.images.length, equals(2));
      expect(roundTrip.aliases.length, equals(3));
      expect(roundTrip.freshnessBadges.length, equals(2));
      expect(roundTrip.nutritionalInfo['Iron'], equals('2.7mg'));
      expect(jsonEncode(roundTrip.toJson()), equals(jsonEncode(json)));
    });

    await testCase('CartItem serialization round-trip', () {
      const p = Product(
        id: 'p_bread',
        name: 'Whole Wheat Bread',
        category: 'Bakery',
        priceCents: 4000,
        mrpCents: 5000,
        imageUrl: 'https://example.com/bread.jpg',
        description: 'Fresh baked bread',
        stock: 15,
      );
      const item = CartItem(product: p, quantity: 2);
      final json = item.toJson();
      final roundTrip = CartItem.fromJson(json);
      expect(roundTrip.product.id, equals('p_bread'));
      expect(roundTrip.quantity, equals(2));
      expect(roundTrip.lineTotal, equals(80.0));
      expect(roundTrip.lineMrpTotal, equals(100.0));
      expect(roundTrip.lineSavings, equals(20.0));
    });
  });

  await testGroup('2. Product.fromJson Corrupt & Missing Data Resilience', () async {
    await testCase('Handles snake_case and legacy field aliases', () {
      final json = {
        'id': 'p_alias',
        'name': 'Ghee',
        'category': 'Dairy',
        'priceCents': 60000,
        'mrp_cents': 75000,
        'pack_unit': '1 L tin',
        'freshness_badges': ['Traditional Bilona'],
        'nutritional_info': {'Purity': '100%'},
        'storage_instructions': 'Room temperature',
        'stock': 10,
      };
      final p = Product.fromJson(json);
      expect(p.mrpCents, equals(75000));
      expect(p.packUnit, equals('1 L tin'));
      expect(p.freshnessBadges.first, equals('Traditional Bilona'));
      expect(p.nutritionalInfo['Purity'], equals('100%'));
    });

    await testCase('Filters non-string corruptions inside list fields', () {
      final json = {
        'id': 'p_corrupt_lists',
        'name': 'Tomatoes',
        'category': 'Vegetables',
        'priceCents': 2000,
        'stock': 10,
        'images': ['https://example.com/t1.jpg', 999, null, false],
        'aliases': ['tamatar', 42, null, 'tomato'],
        'freshnessBadges': ['Farm Fresh', null, true],
      };
      final p = Product.fromJson(json);
      expect(p.images.length, equals(1));
      expect(p.aliases.length, equals(2));
      expect(p.freshnessBadges.length, equals(1));
    });

    await testCase('Missing optional fields default cleanly', () {
      final p = Product.fromJson({
        'id': 'p_min',
        'name': 'Salt',
        'category': 'Staples',
        'priceCents': 2500,
        'stock': 50,
      });
      expect(p.imageUrl, equals(''));
      expect(p.images, isEmpty);
      expect(p.allImages, isEmpty);
      expect(p.mrpCents, isNull);
      expect(p.effectiveMrpCents, equals(2500));
      expect(p.hasDiscount, isFalse);
      expect(p.discountPercentage, equals(0));
    });
  });

  await testGroup('3. Decoupled Screen Imports & Monolithic Leak Audit', () async {
    final screensDir = Directory('lib/screens');
    final screenFiles = screensDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    final undeclaredMonolithIdentifiers = [
      r'\b_Problem\b',
      r'\b_EmptyState\b',
      r'\b_BrandMark\b',
      r'\b_paleGreen\b',
      r'\b_green\b',
      r'\b_yellow\b',
      r'\b_black\b',
      r'\b_muted\b',
      r'\b_paleYellow\b',
    ];

    final violations = <String>[];

    for (final file in screenFiles) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final trimmed = line.trim();
        if (trimmed.startsWith('//') || trimmed.startsWith('/*')) continue;

        for (final pattern in undeclaredMonolithIdentifiers) {
          final regExp = RegExp(pattern);
          if (regExp.hasMatch(line)) {
            final isDeclaration = line.contains('class $pattern') ||
                line.contains('const $pattern') ||
                line.contains('final $pattern');
            if (!isDeclaration) {
              violations.add('${file.path}:${i + 1} ($pattern)');
            }
          }
        }
      }
    }

    await testCase('Audit count of leaked monolithic private identifiers', () {
      print('Total undeclared monolithic identifier leaks across decoupled screens: ${violations.length}');
      // We expect 0 in a properly decoupled codebase; record actual finding
      expect(violations.length, equals(0), 'Found ${violations.length} leaked monolithic identifiers across 9 screen files');
    });

    await testCase('Audit checkout_delivery_form coupling to profile_page', () {
      final file = File('lib/screens/checkout/widgets/checkout_delivery_form.dart');
      final content = file.readAsStringSync();
      final hasCoupling = content.contains("import '../../profile/profile_page.dart';");
      expect(hasCoupling, isFalse, 'checkout_delivery_form.dart contains unnecessary coupling import to profile_page.dart');
    });
  });
}

Future<void> main() async {
  await runAllChallengerVerificationTests();
  globalTestSummary.printReport('Milestone 1 Challenger Adversarial Verification');
}
