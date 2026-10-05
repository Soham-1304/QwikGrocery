import 'dart:convert';
import 'package:qwik_grocery_app/models/banner_item.dart';
import 'package:qwik_grocery_app/models/bill_summary.dart';
import 'package:qwik_grocery_app/models/cart_item.dart';
import 'package:qwik_grocery_app/models/category.dart';
import 'package:qwik_grocery_app/models/product.dart';
import '../harness/test_app_harness.dart';

Future<void> runAdversarialModelTests() async {
  await testGroup('Adversarial: Serialization Round-Trip Integrity', () async {
    await testCase('Category full round-trip preserves all fields', () {
      const original = Category(
        id: 'cat_snacks',
        name: 'Snacks & Munchies',
        iconUrl: 'https://cdn.example.com/icons/chips.png',
        iconName: 'fastfood',
        itemCount: 42,
      );
      final json = original.toJson();
      final reconstructed = Category.fromJson(json);

      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.name, equals(original.name));
      expect(reconstructed.iconUrl, equals(original.iconUrl));
      expect(reconstructed.iconName, equals(original.iconName));
      expect(reconstructed.itemCount, equals(original.itemCount));

      final json2 = reconstructed.toJson();
      expect(jsonEncode(json2), equals(jsonEncode(json)));
    });

    await testCase('BannerItem full round-trip preserves all fields', () {
      const original = BannerItem(
        id: 'banner_summer_mega_sale_2026',
        title: 'Summer Splash Mega Sale',
        subtitle: 'Up to 60% OFF on chilled beverages & ice creams',
        imageUrl: 'https://cdn.example.com/banners/summer.webp',
        actionRoute: '/catalog/summer_deals',
        categoryFilter: 'Beverages',
        backgroundColorHex: '#FF5722',
        badgeText: '60% OFF',
      );
      final json = original.toJson();
      final reconstructed = BannerItem.fromJson(json);

      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.title, equals(original.title));
      expect(reconstructed.subtitle, equals(original.subtitle));
      expect(reconstructed.imageUrl, equals(original.imageUrl));
      expect(reconstructed.actionRoute, equals(original.actionRoute));
      expect(reconstructed.categoryFilter, equals(original.categoryFilter));
      expect(reconstructed.backgroundColorHex, equals(original.backgroundColorHex));
      expect(reconstructed.badgeText, equals(original.badgeText));

      final json2 = reconstructed.toJson();
      expect(jsonEncode(json2), equals(jsonEncode(json)));
    });

    await testCase('BannerItem round-trip with nullable categoryFilter', () {
      const original = BannerItem(
        id: 'banner_generic',
        title: 'Fresh Everyday',
        subtitle: 'Farm produce delivered in 10 mins',
        imageUrl: 'https://cdn.example.com/banners/fresh.png',
      );
      final json = original.toJson();
      expect(json['categoryFilter'], isNull);
      final reconstructed = BannerItem.fromJson(json);
      expect(reconstructed.categoryFilter, isNull);
      expect(reconstructed.backgroundColorHex, equals('#0C831F'));
      expect(jsonEncode(reconstructed.toJson()), equals(jsonEncode(json)));
    });

    await testCase('BillSummary full round-trip preserves all currency and fee fields', () {
      const original = BillSummary(
        itemTotal: 499.50,
        mrpTotal: 650.00,
        mrpSavings: 150.50,
        deliveryFee: 0.0,
        packagingCharge: 10.0,
        taxes: 24.98,
        total: 534.48,
        freeDeliveryThreshold: 199.0,
        amountNeededForFreeDelivery: 0.0,
      );
      final json = original.toJson();
      final reconstructed = BillSummary.fromJson(json);

      expect(reconstructed.itemTotal, equals(original.itemTotal));
      expect(reconstructed.mrpTotal, equals(original.mrpTotal));
      expect(reconstructed.mrpSavings, equals(original.mrpSavings));
      expect(reconstructed.deliveryFee, equals(original.deliveryFee));
      expect(reconstructed.packagingCharge, equals(original.packagingCharge));
      expect(reconstructed.taxes, equals(original.taxes));
      expect(reconstructed.total, equals(original.total));
      expect(reconstructed.freeDeliveryThreshold, equals(original.freeDeliveryThreshold));
      expect(reconstructed.amountNeededForFreeDelivery, equals(original.amountNeededForFreeDelivery));
      expect(reconstructed.hasFreeDelivery, isTrue);

      final json2 = reconstructed.toJson();
      expect(jsonEncode(json2), equals(jsonEncode(json)));
    });

    await testCase('Product full round-trip with all enriched fields explicitly specified', () {
      const original = Product(
        id: 'prod_mango_alphonso_500g',
        name: 'Ratnagiri Alphonso Mango',
        category: 'Fruits',
        priceCents: 49900,
        mrpCents: 75000,
        imageUrl: 'https://cdn.example.com/mango1.jpg',
        images: [
          'https://cdn.example.com/mango1.jpg',
          'https://cdn.example.com/mango2.jpg',
          'https://cdn.example.com/mango3.jpg',
        ],
        description: 'Naturally ripened, sweet GI tagged Ratnagiri Alphonso mangoes.',
        stock: 35,
        brand: 'FARM DIRECT',
        unit: '500 g (2 pcs)',
        packUnit: '500 g box',
        aliases: ['aam', 'alphonso', 'hapoos', 'mango'],
        freshnessBadges: ['GI Tagged', '100% Carbide Free', 'Farm Direct'],
        nutritionalInfo: {
          'Calories': '60 kcal per 100g',
          'Carbohydrates': '15g',
          'Vitamin C': '60% RDA',
          'Fiber': '1.6g',
        },
        storageInstructions: 'Store at room temperature until ripe, then refrigerate.',
        rating: 4.95,
        ratingCount: 342,
      );

      final json = original.toJson();
      final reconstructed = Product.fromJson(json);

      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.name, equals(original.name));
      expect(reconstructed.category, equals(original.category));
      expect(reconstructed.priceCents, equals(original.priceCents));
      expect(reconstructed.mrpCents, equals(original.mrpCents));
      expect(reconstructed.imageUrl, equals(original.imageUrl));
      expect(reconstructed.images.length, equals(original.images.length));
      expect(reconstructed.images[1], equals('https://cdn.example.com/mango2.jpg'));
      expect(reconstructed.description, equals(original.description));
      expect(reconstructed.stock, equals(original.stock));
      expect(reconstructed.brand, equals(original.brand));
      expect(reconstructed.unit, equals(original.unit));
      expect(reconstructed.packUnit, equals(original.packUnit));
      expect(reconstructed.aliases.length, equals(4));
      expect(reconstructed.freshnessBadges.length, equals(3));
      expect(reconstructed.nutritionalInfo['Vitamin C'], equals('60% RDA'));
      expect(reconstructed.storageInstructions, equals(original.storageInstructions));
      expect(reconstructed.rating, equals(4.95));
      expect(reconstructed.ratingCount, equals(342));
      expect(reconstructed.discountPercentage, equals(33));

      final json2 = reconstructed.toJson();
      expect(jsonEncode(json2), equals(jsonEncode(json)));
    });

    await testCase('Product round-trip idempotence on second toJson pass', () {
      const minimal = Product(
        id: 'min_prod',
        name: 'Basic Salt',
        category: 'Staples',
        priceCents: 2000,
        imageUrl: 'https://example.com/salt.jpg',
        description: 'Iodized salt',
        stock: 50,
      );

      final json1 = minimal.toJson();
      final p1 = Product.fromJson(json1);
      final json2 = p1.toJson();
      final p2 = Product.fromJson(json2);
      final json3 = p2.toJson();

      // Once normalized via toJson, subsequent toJson calls must be strictly identical
      expect(jsonEncode(json2), equals(jsonEncode(json3)));
      expect(p1.id, equals(p2.id));
      expect(p1.effectiveMrpCents, equals(p2.effectiveMrpCents));
      expect(jsonEncode(p1.allImages), equals(jsonEncode(p2.allImages)));
      expect(p1.displayUnit, equals(p2.displayUnit));
    });

    await testCase('CartItem round-trip serialization', () {
      const prod = Product(
        id: 'cart_p1',
        name: 'Organic Milk',
        category: 'Dairy',
        priceCents: 6500,
        mrpCents: 7500,
        imageUrl: 'https://example.com/milk.jpg',
        description: 'Cow milk',
        stock: 10,
      );
      const original = CartItem(product: prod, quantity: 3);
      final json = original.toJson();
      final reconstructed = CartItem.fromJson(json);

      expect(reconstructed.product.id, equals('cart_p1'));
      expect(reconstructed.quantity, equals(3));
      expect(reconstructed.lineTotal, equals(195.0));
      expect(reconstructed.lineMrpTotal, equals(225.0));
      expect(reconstructed.lineSavings, equals(30.0));
      expect(reconstructed.totalCents, equals(19500));
      expect(reconstructed.totalMrpCents, equals(22500));
    });
  });

  await testGroup('Adversarial: Resilience against corrupt/missing JSON in Product.fromJson', () async {
    await testCase('Product.fromJson parses snake_case aliases (mrp_cents, pack_unit, freshness_badges, nutritional_info, storage_instructions)', () {
      final json = {
        'id': 'snake_1',
        'name': 'Ghee',
        'category': 'Dairy',
        'priceCents': 55000,
        'mrp_cents': 65000,
        'stock': 12,
        'pack_unit': '500 ml jar',
        'freshness_badges': ['Pure Cow Ghee', 'No Preservatives'],
        'nutritional_info': {'Fat': '99.5g', 'Energy': '897 kcal'},
        'storage_instructions': 'Store in a cool dry place',
      };
      final prod = Product.fromJson(json);
      expect(prod.mrpCents, equals(65000));
      expect(prod.packUnit, equals('500 ml jar'));
      expect(prod.freshnessBadges.length, equals(2));
      expect(prod.nutritionalInfo['Fat'], equals('99.5g'));
      expect(prod.storageInstructions, equals('Store in a cool dry place'));
    });

    await testCase('Product.fromJson parses legacy raw mrp field as num or string', () {
      final json1 = {
        'id': 'legacy_1',
        'name': 'Paneer',
        'category': 'Dairy',
        'priceCents': 9000,
        'mrp': 11000, // integer num
        'stock': 8,
      };
      final prod1 = Product.fromJson(json1);
      expect(prod1.mrpCents, equals(11000));

      final json2 = {
        'id': 'legacy_2',
        'name': 'Butter',
        'category': 'Dairy',
        'priceCents': 5000,
        'mrp': '5800', // string representation of int
        'stock': 14,
      };
      final prod2 = Product.fromJson(json2);
      expect(prod2.mrpCents, equals(5800));
    });

    await testCase('Product.fromJson gracefully filters non-string values inside images list', () {
      final json = {
        'id': 'corrupt_images',
        'name': 'Apples',
        'category': 'Fruits',
        'priceCents': 15000,
        'stock': 10,
        'images': [
          'https://example.com/apple1.jpg',
          12345, // corrupt int
          null, // corrupt null
          {'nested': 'object'}, // corrupt map
          'https://example.com/apple2.jpg',
          false, // corrupt bool
        ],
      };
      final prod = Product.fromJson(json);
      expect(prod.images.length, equals(2));
      expect(prod.images[0], equals('https://example.com/apple1.jpg'));
      expect(prod.images[1], equals('https://example.com/apple2.jpg'));
    });

    await testCase('Product.fromJson gracefully filters non-string values inside aliases and freshnessBadges', () {
      final json = {
        'id': 'corrupt_lists',
        'name': 'Spinach',
        'category': 'Vegetables',
        'priceCents': 3000,
        'stock': 5,
        'aliases': ['palak', 99, null, 'green leafy'],
        'freshnessBadges': [null, 'Hydroponic', true, 42],
      };
      final prod = Product.fromJson(json);
      expect(prod.aliases.length, equals(2));
      expect(prod.aliases[0], equals('palak'));
      expect(prod.aliases[1], equals('green leafy'));
      expect(prod.freshnessBadges.length, equals(1));
      expect(prod.freshnessBadges[0], equals('Hydroponic'));
    });

    await testCase('Product.fromJson safely stringifies non-string nutritionalInfo entries', () {
      final json = {
        'id': 'corrupt_nutrition',
        'name': 'Almonds',
        'category': 'Dry Fruits',
        'priceCents': 80000,
        'stock': 20,
        'nutritionalInfo': {
          'calories': 579, // num value
          'organic': true, // bool value
          'allergens': ['tree nuts'], // list value
        },
      };
      final prod = Product.fromJson(json);
      expect(prod.nutritionalInfo['calories'], equals('579'));
      expect(prod.nutritionalInfo['organic'], equals('true'));
      expect(prod.nutritionalInfo['allergens'], contains('tree nuts'));
    });

    await testCase('Product.fromJson handles missing optional fields with safe defaults', () {
      final minimalJson = {
        'id': 'minimal_json',
        'name': 'Watermelon',
        'category': 'Fruits',
        'priceCents': 8000,
        'stock': 3,
      };
      final prod = Product.fromJson(minimalJson);
      expect(prod.imageUrl, equals(''));
      expect(prod.images, isEmpty);
      expect(prod.description, equals(''));
      expect(prod.brand, equals(''));
      expect(prod.unit, equals(''));
      expect(prod.packUnit, equals(''));
      expect(prod.aliases, isEmpty);
      expect(prod.freshnessBadges, isEmpty);
      expect(prod.nutritionalInfo, isEmpty);
      expect(prod.storageInstructions, equals(''));
      expect(prod.rating, equals(4.8));
      expect(prod.ratingCount, equals(120));
      expect(prod.mrpCents, isNull);
      expect(prod.effectiveMrpCents, equals(8000));
      expect(prod.hasDiscount, isFalse);
    });

    await testCase('Product.fromJson handles double priceCents and stock numbers', () {
      final json = {
        'id': 'double_num',
        'name': 'Sugar',
        'category': 'Staples',
        'priceCents': 4500.0, // double
        'stock': 20.0, // double
      };
      final prod = Product.fromJson(json);
      expect(prod.priceCents, equals(4500));
      expect(prod.stock, equals(20));
    });

    await testCase('Product calculation edge cases: zero stock, negative mrp, huge numbers', () {
      const outOfStock = Product(
        id: 'zero_stock',
        name: 'Rare Saffron',
        category: 'Spices',
        priceCents: 50000,
        imageUrl: '',
        description: '',
        stock: 0,
      );
      expect(outOfStock.available, isFalse);

      // mrpCents <= 0 falls back to priceCents
      const negativeMrp = Product(
        id: 'neg_mrp',
        name: 'Item',
        category: 'Cat',
        priceCents: 2000,
        mrpCents: -500,
        imageUrl: '',
        description: '',
        stock: 5,
      );
      expect(negativeMrp.effectiveMrpCents, equals(2000));
      expect(negativeMrp.hasDiscount, isFalse);
      expect(negativeMrp.discountPercentage, equals(0));

      // Huge price and stock
      const huge = Product(
        id: 'huge_num',
        name: 'Bulk Rice',
        category: 'Staples',
        priceCents: 100000000, // 1,000,000 INR
        mrpCents: 120000000,
        imageUrl: '',
        description: '',
        stock: 100000,
      );
      expect(huge.price, equals(1000000.0));
      expect(huge.mrp, equals(1200000.0));
      expect(huge.savings, equals(200000.0));
      expect(huge.discountPercentage, equals(17));
    });

    await testCase('Product.fromJson behavior on missing required fields', () {
      // Test missing id
      bool threwOnMissingId = false;
      try {
        Product.fromJson({
          'name': 'Apple',
          'category': 'Fruits',
          'priceCents': 5000,
          'stock': 10,
        });
      } catch (e) {
        threwOnMissingId = true;
      }
      expect(threwOnMissingId, isTrue);

      // Test string priceCents
      bool threwOnStringPrice = false;
      try {
        Product.fromJson({
          'id': 'p1',
          'name': 'Apple',
          'category': 'Fruits',
          'priceCents': '5000', // string instead of num
          'stock': 10,
        });
      } catch (e) {
        threwOnStringPrice = true;
      }
      expect(threwOnStringPrice, isTrue);

      // Test string stock
      bool threwOnStringStock = false;
      try {
        Product.fromJson({
          'id': 'p1',
          'name': 'Apple',
          'category': 'Fruits',
          'priceCents': 5000,
          'stock': '10', // string instead of num
        });
      } catch (e) {
        threwOnStringStock = true;
      }
      expect(threwOnStringStock, isTrue);

      // Test snake_case price_cents fallback (currently missing in Product.fromJson)
      bool threwOnSnakeCasePriceOnly = false;
      try {
        Product.fromJson({
          'id': 'p1',
          'name': 'Apple',
          'category': 'Fruits',
          'price_cents': 5000, // snake_case instead of camelCase
          'stock': 10,
        });
      } catch (e) {
        threwOnSnakeCasePriceOnly = true;
      }
      expect(threwOnSnakeCasePriceOnly, isTrue);
    });
  });
}

Future<void> main() async {
  await runAdversarialModelTests();
  globalTestSummary.printReport('Tier 1 Adversarial Model Stress Tests');
}
