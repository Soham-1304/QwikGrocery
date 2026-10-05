import 'package:qwik_grocery_app/models/banner_item.dart';
import 'package:qwik_grocery_app/models/category.dart';
import 'package:qwik_grocery_app/models/customer_profile.dart';
import 'package:qwik_grocery_app/models/grocery_order.dart';
import 'package:qwik_grocery_app/models/grocery_subscription.dart';
import 'package:qwik_grocery_app/models/product.dart';
import 'package:qwik_grocery_app/models/wallet.dart';

/// Seeded hermetic fixtures for tests.
class TestFixtures {
  const TestFixtures._();

  // Products
  static final Product p1Onions = Product(
    id: 'prod_onions',
    name: 'Farm Fresh Onions',
    category: 'Vegetables',
    priceCents: 3500, // ₹35.00
    mrpCents: 5000,   // ₹50.00 (30% OFF)
    imageUrl: 'https://images.unsplash.com/photo-onions.jpg',
    images: [
      'https://images.unsplash.com/photo-onions-1.jpg',
      'https://images.unsplash.com/photo-onions-2.jpg',
    ],
    description: 'Crisp and pungent farm fresh red onions.',
    stock: 25,
    brand: 'FARM PICK',
    unit: '1 kg',
    packUnit: '1 kg',
    aliases: ['pyaz', 'kanda', 'onion'],
    freshnessBadges: ['Direct from Farm', '100% Quality Guarantee'],
    nutritionalInfo: {'Calories': '40 kcal', 'Carbs': '9 g', 'Fiber': '1.7 g'},
    storageInstructions: 'Store in a cool, dry, well-ventilated space.',
  );

  static final Product p2Potatoes = Product(
    id: 'prod_potatoes',
    name: 'Organic Potatoes',
    category: 'Vegetables',
    priceCents: 4000, // ₹40.00
    mrpCents: 5500,   // ₹55.00 (27% OFF)
    imageUrl: 'https://images.unsplash.com/photo-potatoes.jpg',
    images: ['https://images.unsplash.com/photo-potatoes-1.jpg'],
    description: 'Pesticide-free highland organic potatoes.',
    stock: 20,
    brand: 'ORGANIC INDIA',
    unit: '1 kg',
    packUnit: '1 kg',
    aliases: ['aloo', 'batata', 'potato'],
    freshnessBadges: ['100% Organic', 'Cold Chain Maintained'],
    nutritionalInfo: {'Calories': '77 kcal', 'Carbs': '17 g', 'Potassium': '421 mg'},
    storageInstructions: 'Keep in dark, dry pantry away from onions.',
  );

  static final Product p3Tomatoes = Product(
    id: 'prod_tomatoes',
    name: 'Fresh Hybrid Tomatoes',
    category: 'Vegetables',
    priceCents: 2500, // ₹25.00
    mrpCents: 3500,   // ₹35.00
    imageUrl: 'https://images.unsplash.com/photo-tomatoes.jpg',
    description: 'Juicy, plump red salad tomatoes.',
    stock: 15,
    brand: 'FARM PICK',
    unit: '500 g',
    packUnit: '500 g',
    aliases: ['tamatar', 'tomato'],
    freshnessBadges: ['Direct from Farm'],
  );

  static final Product p4Milk = Product(
    id: 'prod_milk',
    name: 'Full Cream Fresh Milk',
    category: 'Dairy & Breakfast',
    priceCents: 6800, // ₹68.00
    mrpCents: 7200,   // ₹72.00
    imageUrl: 'https://images.unsplash.com/photo-milk.jpg',
    images: [
      'https://images.unsplash.com/photo-milk-front.jpg',
      'https://images.unsplash.com/photo-milk-back.jpg',
    ],
    description: 'Pasteurized homogenized cow milk with 6% fat.',
    stock: 30,
    brand: 'AMUL',
    unit: '1 L',
    packUnit: '1 L pouch',
    aliases: ['doodh', 'milk', 'gold milk'],
    freshnessBadges: ['Cold Chain Maintained', '100% Quality Guarantee'],
    nutritionalInfo: {'Protein': '3.2 g', 'Calcium': '120 mg', 'Fat': '6.0 g'},
    storageInstructions: 'Refrigerate at 4°C or below.',
  );

  static final Product p5Curd = Product(
    id: 'prod_curd',
    name: 'Thick Dahi / Fresh Curd',
    category: 'Dairy & Breakfast',
    priceCents: 3500, // ₹35.00
    mrpCents: 4000,   // ₹40.00
    imageUrl: 'https://images.unsplash.com/photo-curd.jpg',
    description: 'Creamy, probiotic rich homestyle set curd.',
    stock: 12,
    brand: 'MOTHER DAIRY',
    unit: '400 g',
    packUnit: '400 g cup',
    aliases: ['dahi', 'yogurt', 'curd'],
    freshnessBadges: ['Cold Chain Maintained'],
  );

  static final Product p6Butter = Product(
    id: 'prod_butter',
    name: 'Pasteurized Salted Butter',
    category: 'Dairy & Breakfast',
    priceCents: 5800, // ₹58.00
    mrpCents: 6000,   // ₹60.00
    imageUrl: 'https://images.unsplash.com/photo-butter.jpg',
    description: 'Delicious creamy butter made from pure milk fat.',
    stock: 18,
    brand: 'AMUL',
    unit: '100 g',
    packUnit: '100 g carton',
    aliases: ['makhan', 'butter'],
    freshnessBadges: ['Cold Chain Maintained'],
  );

  static final Product p7Atta = Product(
    id: 'prod_atta',
    name: 'Sharbati Whole Wheat Atta',
    category: 'Atta, Rice & Dal',
    priceCents: 26000, // ₹260.00
    mrpCents: 29500,   // ₹295.00
    imageUrl: 'https://images.unsplash.com/photo-atta.jpg',
    description: '100% MP Sharbati wheat grains stone-ground flour.',
    stock: 10,
    brand: 'AASHIRVAAD',
    unit: '5 kg',
    packUnit: '5 kg bag',
    aliases: ['gehu', 'atta', 'flour'],
    freshnessBadges: ['100% Quality Guarantee'],
  );

  static final Product p8Rice = Product(
    id: 'prod_rice',
    name: 'Traditional Basmati Rice',
    category: 'Atta, Rice & Dal',
    priceCents: 14500, // ₹145.00
    mrpCents: 18000,   // ₹180.00
    imageUrl: 'https://images.unsplash.com/photo-rice.jpg',
    description: 'Extra long grain aged aromatic Basmati rice.',
    stock: 8,
    brand: 'DAAWAT',
    unit: '1 kg',
    packUnit: '1 kg pouch',
    aliases: ['chawal', 'basmati', 'rice'],
  );

  static final Product p9Dal = Product(
    id: 'prod_dal',
    name: 'Unpolished Toor Dal',
    category: 'Atta, Rice & Dal',
    priceCents: 17500, // ₹175.00
    mrpCents: 21000,   // ₹210.00
    imageUrl: 'https://images.unsplash.com/photo-dal.jpg',
    description: 'High protein unpolished arhar / toor dal.',
    stock: 15,
    brand: 'TATA SAMPANN',
    unit: '1 kg',
    packUnit: '1 kg bag',
    aliases: ['arhar', 'toor', 'dal', 'lentil'],
    freshnessBadges: ['100% Quality Guarantee'],
  );

  static final Product p10Chips = Product(
    id: 'prod_chips',
    name: 'Classic Salted Potato Chips',
    category: 'Snacks & Munchies',
    priceCents: 2000, // ₹20.00
    mrpCents: 2000,   // ₹20.00 (No discount)
    imageUrl: 'https://images.unsplash.com/photo-chips.jpg',
    description: 'Thin crispy potato wafers with light sea salt.',
    stock: 40,
    brand: 'LAYS',
    unit: '50 g',
    packUnit: '50 g pack',
    aliases: ['chips', 'wafers', 'snack'],
  );

  static final Product p11Almonds = Product(
    id: 'prod_almonds',
    name: 'California Roasted Almonds',
    category: 'Snacks & Munchies',
    priceCents: 24900, // ₹249.00
    mrpCents: 32000,   // ₹320.00
    imageUrl: 'https://images.unsplash.com/photo-almonds.jpg',
    description: 'Crunchy lightly salted jumbo California badam.',
    stock: 5,
    brand: 'NUTTY CRUNCH',
    unit: '200 g',
    packUnit: '200 g jar',
    aliases: ['badam', 'dry fruits', 'almonds'],
    freshnessBadges: ['100% Quality Guarantee'],
  );

  static final Product p12Juice = Product(
    id: 'prod_juice',
    name: 'Cold Pressed Orange Juice',
    category: 'Cold Drinks & Juices',
    priceCents: 8000, // ₹80.00
    mrpCents: 10000,  // ₹100.00
    imageUrl: 'https://images.unsplash.com/photo-juice.jpg',
    description: '100% pure Valencia orange juice with zero added sugar.',
    stock: 10,
    brand: 'RAW PRESSERY',
    unit: '250 ml',
    packUnit: '250 ml bottle',
    aliases: ['santre ka juice', 'juice', 'beverage'],
    freshnessBadges: ['Cold Chain Maintained'],
  );

  static final Product p13Cookies = Product(
    id: 'prod_cookies',
    name: 'Dark Chocolate Chip Cookies',
    category: 'Bakery & Biscuits',
    priceCents: 4000, // ₹40.00
    mrpCents: 5000,   // ₹50.00
    imageUrl: 'https://images.unsplash.com/photo-cookies.jpg',
    description: 'Rich crispy cookies studded with real dark chocolate chips.',
    stock: 25,
    brand: 'HIDE & SEEK',
    unit: '120 g',
    packUnit: '120 g pack',
    aliases: ['biscuit', 'cookie', 'chocolate'],
  );

  // Boundary condition products:
  static final Product p14OutOfStock = Product(
    id: 'prod_berries',
    name: 'Imported Fresh Blueberries',
    category: 'Vegetables',
    priceCents: 29900, // ₹299.00
    mrpCents: 35000,   // ₹350.00
    imageUrl: 'https://images.unsplash.com/photo-berries.jpg',
    description: 'Sweet and tart fresh Chilean blueberries.',
    stock: 0, // OUT OF STOCK!
    brand: 'BERRY FRESH',
    unit: '125 g',
    packUnit: '125 g clamshell',
    aliases: ['blueberries', 'exotic berries'],
  );

  static final Product p15CappedStock = Product(
    id: 'prod_saffron',
    name: 'Kashmiri Mogra Saffron',
    category: 'Atta, Rice & Dal',
    priceCents: 19900, // ₹199.00
    mrpCents: 25000,   // ₹250.00
    imageUrl: 'https://images.unsplash.com/photo-saffron.jpg',
    description: 'Grade-A natural Kashmiri saffron strands.',
    stock: 2, // EXACT STOCK CAP OF 2!
    brand: 'KASHMIR SELECT',
    unit: '1 g',
    packUnit: '1 g blister',
    aliases: ['kesar', 'zafran', 'saffron'],
  );

  static List<Product> get allProducts => [
    p1Onions,
    p2Potatoes,
    p3Tomatoes,
    p4Milk,
    p5Curd,
    p6Butter,
    p7Atta,
    p8Rice,
    p9Dal,
    p10Chips,
    p11Almonds,
    p12Juice,
    p13Cookies,
    p14OutOfStock,
    p15CappedStock,
  ];

  // Categories
  static final List<Category> allCategories = [
    const Category(id: 'cat_all', name: 'All', iconName: 'apps', itemCount: 15),
    const Category(id: 'cat_veg', name: 'Vegetables', iconName: 'eco', itemCount: 4),
    const Category(id: 'cat_dairy', name: 'Dairy & Breakfast', iconName: 'egg', itemCount: 3),
    const Category(id: 'cat_staples', name: 'Atta, Rice & Dal', iconName: 'grain', itemCount: 4),
    const Category(id: 'cat_snacks', name: 'Snacks & Munchies', iconName: 'fastfood', itemCount: 2),
    const Category(id: 'cat_drinks', name: 'Cold Drinks & Juices', iconName: 'local_drink', itemCount: 1),
    const Category(id: 'cat_bakery', name: 'Bakery & Biscuits', iconName: 'cake', itemCount: 1),
  ];

  // Promotional Hero Banners
  static final List<BannerItem> allBanners = [
    const BannerItem(
      id: 'banner_1',
      title: 'FLAT 50% OFF Fresh Veggies',
      subtitle: 'Harvested this morning from local farms',
      imageUrl: 'https://example.com/banner-veggies.png',
      badgeText: '50% OFF',
      categoryFilter: 'Vegetables',
    ),
    const BannerItem(
      id: 'banner_2',
      title: 'Dairy & Breakfast Fest',
      subtitle: 'Cold-chain milk, curd & butter delivered in 10 mins',
      imageUrl: 'https://example.com/banner-dairy.png',
      badgeText: 'FRESH DAILY',
      categoryFilter: 'Dairy & Breakfast',
    ),
    const BannerItem(
      id: 'banner_3',
      title: 'Weekend Snack Craving?',
      subtitle: 'Crunchy chips, dry fruits & chilled beverages',
      imageUrl: 'https://example.com/banner-snacks.png',
      badgeText: 'MIN 20% OFF',
      categoryFilter: 'Snacks & Munchies',
    ),
  ];

  // Addresses
  static const SavedAddress addrHome = SavedAddress(
    id: 'addr_home',
    label: 'Home',
    recipientName: 'Aarav Sharma',
    phone: '9876543210',
    line1: 'Flat 402, Green Meadows',
    line2: '12th Cross, Indiranagar',
    landmark: 'Near Metro Station',
    city: 'Bengaluru',
    state: 'Karnataka',
    postalCode: '560038',
    latitude: 12.9784,
    longitude: 77.6408,
  );

  static const SavedAddress addrWork = SavedAddress(
    id: 'addr_work',
    label: 'Work',
    recipientName: 'Aarav Sharma',
    phone: '9876543210',
    line1: 'Tower B, 7th Floor, Embassy Tech Village',
    line2: 'Outer Ring Road, Bellandur',
    landmark: 'Opposite New Horizon College',
    city: 'Bengaluru',
    state: 'Karnataka',
    postalCode: '560103',
    latitude: 12.9260,
    longitude: 77.6925,
  );

  // Customer Profile
  static const CustomerProfile profile = CustomerProfile(
    name: 'Aarav Sharma',
    email: 'aarav.sharma@example.com',
    addresses: [addrHome, addrWork],
    paymentMethods: [
      SavedPaymentMethod(
        id: 'pm_upi_1',
        type: 'upi',
        label: 'Google Pay UPI',
        upiId: 'aarav@okaxis',
      ),
      SavedPaymentMethod(
        id: 'pm_card_1',
        type: 'card',
        label: 'HDFC Bank Credit Card',
        lastFour: '8842',
      ),
    ],
  );

  // Initial Wallet
  static final WalletSummary initialWallet = WalletSummary(
    balanceCents: 50000, // ₹500.00
    transactions: [
      WalletTransaction(
        id: 'tx_init',
        type: 'credit',
        amountCents: 50000,
        balanceAfterCents: 50000,
        note: 'Welcome Bonus Credits',
        createdAt: DateTime(2026, 10, 1, 10, 0),
      ),
    ],
  );

  // Seeded Orders
  static final List<GroceryOrder> pastOrders = [
    GroceryOrder(
      id: 'ORD-9821',
      status: 'delivered',
      totalCents: 34500, // ₹345.00
      createdAt: DateTime(2026, 10, 2, 14, 30),
      address: addrHome.formatted,
      items: [
        {'productId': 'prod_onions', 'name': 'Farm Fresh Onions', 'quantity': 2, 'priceCents': 3500},
        {'productId': 'prod_atta', 'name': 'Sharbati Whole Wheat Atta', 'quantity': 1, 'priceCents': 26000},
      ],
      delivery: {'partnerName': 'Ramesh Kumar', 'partnerPhone': '9876501234'},
      deliveryLocation: {'latitude': 12.9784, 'longitude': 77.6408},
    ),
  ];

  // Seeded Subscriptions
  static final List<GrocerySubscription> activeSubscriptions = [
    GrocerySubscription(
      id: 'sub_daily_milk',
      active: true,
      frequency: 'daily',
      deliveryTime: '07:00 AM',
      startDate: DateTime(2026, 10, 1),
      nextRunAt: DateTime(2026, 10, 5),
      address: addrHome.formatted,
      addressId: addrHome.id,
      items: [
        ScheduledItem(
          productId: p4Milk.id,
          productName: p4Milk.name,
          quantity: 2,
          unitPriceCents: p4Milk.priceCents,
        ),
      ],
    ),
  ];
}
