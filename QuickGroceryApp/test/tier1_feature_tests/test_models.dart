import 'package:qwik_grocery_app/models/banner_item.dart';
import 'package:qwik_grocery_app/models/bill_summary.dart';
import 'package:qwik_grocery_app/models/cart_item.dart';
import 'package:qwik_grocery_app/models/category.dart';
import 'package:qwik_grocery_app/models/product.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_fixtures.dart';

Future<void> runModelTests() async {
  await testGroup('Tier 1: Enriched Product Models', () async {
    await testCase('Product instantiation sets all enriched fields correctly', () {
      final p = TestFixtures.p1Onions;
      expect(p.id, equals('prod_onions'));
      expect(p.name, equals('Farm Fresh Onions'));
      expect(p.brand, equals('FARM PICK'));
      expect(p.unit, equals('1 kg'));
      expect(p.packUnit, equals('1 kg'));
      expect(p.priceCents, equals(3500));
      expect(p.price, equals(35.0));
      expect(p.mrpCents, equals(5000));
      expect(p.mrp, equals(50.0));
      expect(p.stock, equals(25));
    });

    await testCase('Product discountPercentage is computed correctly', () {
      // 50 MRP - 35 Price = 15 savings / 50 = 30% discount
      expect(TestFixtures.p1Onions.discountPercentage, equals(30));
      // Product with no discount (mrp == price) has 0% discount
      expect(TestFixtures.p10Chips.discountPercentage, equals(0));
      expect(TestFixtures.p10Chips.hasDiscount, isFalse);
    });

    await testCase('Product available property reflects stock count', () {
      expect(TestFixtures.p1Onions.available, isTrue);
      expect(TestFixtures.p14OutOfStock.available, isFalse);
    });

    await testCase('Product displayUnit prefers packUnit over unit', () {
      expect(TestFixtures.p4Milk.displayUnit, equals('1 L pouch'));
      const fallbackProd = Product(
        id: 'fallback_1',
        name: 'Loose Apples',
        category: 'Fruits',
        priceCents: 10000,
        imageUrl: '',
        description: '',
        stock: 5,
        unit: '500 g',
      );
      expect(fallbackProd.displayUnit, equals('500 g'));
    });

    await testCase('Product fromJson parses and calculates effective MRP', () {
      final json = {
        'id': 'json_prod_1',
        'name': 'Greek Yogurt',
        'category': 'Dairy & Breakfast',
        'priceCents': 5000,
        'mrpCents': 6000,
        'imageUrl': 'https://example.com/yogurt.jpg',
        'description': 'High protein yogurt',
        'stock': 15,
        'brand': 'EPIGAMIA',
        'unit': '100 g',
        'aliases': ['yogurt', 'curd'],
        'freshnessBadges': ['Cold Chain Maintained'],
      };
      final prod = Product.fromJson(json);
      expect(prod.id, equals('json_prod_1'));
      expect(prod.price, equals(50.0));
      expect(prod.mrp, equals(60.0));
      expect(prod.hasDiscount, isTrue);
      expect(prod.discountPercentage, equals(17)); // (10/60) * 100 = 16.66% -> 17%
      expect(prod.aliases.length, equals(2));
    });

    await testCase('Product toJson serializes all necessary fields', () {
      final p = TestFixtures.p2Potatoes;
      final json = p.toJson();
      expect(json['id'], equals('prod_potatoes'));
      expect(json['name'], equals('Organic Potatoes'));
      expect(json['priceCents'], equals(4000));
      expect(json['mrpCents'], equals(5500));
      expect(json['stock'], equals(20));
      expect(json['brand'], equals('ORGANIC INDIA'));
    });

    await testCase('CartItem computes lineTotal, lineMrpTotal, and lineSavings accurately', () {
      final item = CartItem(product: TestFixtures.p1Onions, quantity: 3);
      // Selling price 35 * 3 = 105.0
      expect(item.lineTotal, equals(105.0));
      // MRP 50 * 3 = 150.0
      expect(item.lineMrpTotal, equals(150.0));
      // Savings 150 - 105 = 45.0
      expect(item.lineSavings, equals(45.0));
      expect(item.totalCents, equals(10500));
    });

    await testCase('CartItem copyWith and withQuantity immutability', () {
      final original = CartItem(product: TestFixtures.p1Onions, quantity: 1);
      final updated = original.withQuantity(4);
      expect(original.quantity, equals(1));
      expect(updated.quantity, equals(4));
      expect(updated.product.id, equals(original.product.id));
    });

    await testCase('Category model fromJson and toJson', () {
      final cat = Category.fromJson({
        'id': 'cat_fruits',
        'name': 'Fresh Fruits',
        'iconName': 'apple',
        'itemCount': 12,
      });
      expect(cat.id, equals('cat_fruits'));
      expect(cat.name, equals('Fresh Fruits'));
      expect(cat.itemCount, equals(12));
      expect(cat.toJson()['name'], equals('Fresh Fruits'));
    });

    await testCase('BannerItem and BillSummary models serialization', () {
      final banner = TestFixtures.allBanners.first;
      expect(banner.title, contains('50% OFF'));
      expect(banner.badgeText, equals('50% OFF'));
      expect(banner.categoryFilter, equals('Vegetables'));

      const bill = BillSummary(
        itemTotal: 300.0,
        mrpTotal: 400.0,
        mrpSavings: 100.0,
        deliveryFee: 0.0,
        packagingCharge: 10.0,
        taxes: 15.0,
        total: 325.0,
        freeDeliveryThreshold: 199.0,
      );
      expect(bill.hasFreeDelivery, isTrue);
      expect(bill.total, equals(325.0));
      final billJson = bill.toJson();
      expect(billJson['total'], equals(325.0));
      expect(billJson['mrpSavings'], equals(100.0));
    });
  });
}

Future<void> main() async {
  await runModelTests();
  globalTestSummary.printReport('Tier 1 Models');
}
