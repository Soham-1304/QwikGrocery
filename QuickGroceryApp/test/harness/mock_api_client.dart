import 'dart:async';

import 'package:qwik_grocery_app/models/customer_profile.dart';
import 'package:qwik_grocery_app/models/grocery_order.dart';
import 'package:qwik_grocery_app/models/grocery_subscription.dart';
import 'package:qwik_grocery_app/models/product.dart';
import 'package:qwik_grocery_app/models/wallet.dart';
import 'package:qwik_grocery_app/services/api_exception.dart';
import 'test_fixtures.dart';

/// Hermetic in-memory mock client implementing all QuickGrocery API contracts.
class MockApiClient {
  MockApiClient({
    List<Product>? seedProducts,
    CustomerProfile? seedProfile,
    WalletSummary? seedWallet,
    List<GroceryOrder>? seedOrders,
    List<GrocerySubscription>? seedSubscriptions,
  })  : _products = List.of(seedProducts ?? TestFixtures.allProducts),
        _profile = seedProfile ?? TestFixtures.profile,
        _wallet = seedWallet ?? TestFixtures.initialWallet,
        _orders = List.of(seedOrders ?? TestFixtures.pastOrders),
        _subscriptions = List.of(seedSubscriptions ?? TestFixtures.activeSubscriptions);

  List<Product> _products;
  CustomerProfile _profile;
  WalletSummary _wallet;
  final List<GroceryOrder> _orders;
  final List<GrocerySubscription> _subscriptions;

  final Map<String, int> _endpointCallCounts = {};

  bool simulateNetworkError = false;
  int? forcedStatusCode;
  String? forcedErrorMessage;

  int callCount(String endpoint) => _endpointCallCounts[endpoint] ?? 0;

  void resetCallCounts() => _endpointCallCounts.clear();

  void _recordCall(String endpoint) {
    _endpointCallCounts[endpoint] = (_endpointCallCounts[endpoint] ?? 0) + 1;
    if (simulateNetworkError) {
      throw ApiException(
        forcedErrorMessage ?? 'Simulated Network Failure',
        statusCode: forcedStatusCode ?? 500,
      );
    }
  }

  /// Fetches products filtered by search query, category, and availability.
  Future<List<Product>> products({
    String search = '',
    String category = '',
    bool? available,
  }) async {
    _recordCall('products');
    final query = search.trim().toLowerCase();

    return _products.where((prod) {
      // Category filter
      if (category.isNotEmpty && category != 'All' && prod.category != category) {
        return false;
      }

      // Availability filter
      if (available != null && prod.available != available) {
        return false;
      }

      // Search matching across name, brand, and aliases
      if (query.isNotEmpty) {
        final matchesName = prod.name.toLowerCase().contains(query);
        final matchesBrand = prod.brand.toLowerCase().contains(query);
        final matchesAlias = prod.aliases.any((alias) => alias.toLowerCase().contains(query));
        if (!matchesName && !matchesBrand && !matchesAlias) {
          return false;
        }
      }

      return true;
    }).toList(growable: false);
  }

  /// Fetches a single product by ID.
  Future<Product> product(String id) async {
    _recordCall('product');
    final match = _products.where((p) => p.id == id).firstOrNull;
    if (match == null) {
      throw ApiException('Product not found: $id', statusCode: 404);
    }
    return match;
  }

  /// Fetches the customer profile.
  Future<CustomerProfile> profile() async {
    _recordCall('profile');
    return _profile;
  }

  /// Updates profile display name.
  Future<void> saveProfileName(String name) async {
    _recordCall('saveProfileName');
    _profile = CustomerProfile(
      name: name,
      email: _profile.email,
      addresses: _profile.addresses,
      paymentMethods: _profile.paymentMethods,
    );
  }

  /// Adds a new delivery address.
  Future<SavedAddress> addAddress(SavedAddress address) async {
    _recordCall('addAddress');
    final generatedId = address.id.isNotEmpty
        ? address.id
        : 'addr_${DateTime.now().millisecondsSinceEpoch}';
    final created = SavedAddress(
      id: generatedId,
      label: address.label,
      recipientName: address.recipientName,
      phone: address.phone,
      line1: address.line1,
      line2: address.line2,
      landmark: address.landmark,
      city: address.city,
      state: address.state,
      postalCode: address.postalCode,
      latitude: address.latitude,
      longitude: address.longitude,
    );

    final updated = List<SavedAddress>.from(_profile.addresses)..add(created);
    _profile = CustomerProfile(
      name: _profile.name,
      email: _profile.email,
      addresses: updated,
      paymentMethods: _profile.paymentMethods,
    );
    return created;
  }

  /// Deletes a saved address by ID.
  Future<void> deleteAddress(String id) async {
    _recordCall('deleteAddress');
    final updated = _profile.addresses.where((a) => a.id != id).toList();
    _profile = CustomerProfile(
      name: _profile.name,
      email: _profile.email,
      addresses: updated,
      paymentMethods: _profile.paymentMethods,
    );
  }

  /// Adds a payment method (Card or UPI).
  Future<SavedPaymentMethod> addPaymentMethod({
    required String type,
    required String label,
    String lastFour = '',
    String upiId = '',
  }) async {
    _recordCall('addPaymentMethod');
    final created = SavedPaymentMethod(
      id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      label: label,
      lastFour: lastFour,
      upiId: upiId,
    );

    final updated = List<SavedPaymentMethod>.from(_profile.paymentMethods)..add(created);
    _profile = CustomerProfile(
      name: _profile.name,
      email: _profile.email,
      addresses: _profile.addresses,
      paymentMethods: updated,
    );
    return created;
  }

  /// Deletes a saved payment method.
  Future<void> deletePaymentMethod(String id) async {
    _recordCall('deletePaymentMethod');
    final updated = _profile.paymentMethods.where((pm) => pm.id != id).toList();
    _profile = CustomerProfile(
      name: _profile.name,
      email: _profile.email,
      addresses: _profile.addresses,
      paymentMethods: updated,
    );
  }

  /// Fetches order history for customer.
  Future<List<GroceryOrder>> orders() async {
    _recordCall('orders');
    return List.unmodifiable(_orders);
  }

  /// Fetches single order by ID.
  Future<GroceryOrder> order(String id) async {
    _recordCall('order');
    final match = _orders.where((o) => o.id == id).firstOrNull;
    if (match == null) {
      throw ApiException('Order not found: $id', statusCode: 404);
    }
    return match;
  }

  /// Creates and places a new order.
  Future<GroceryOrder> createOrder({
    required List<dynamic> items,
    required String name,
    required String phone,
    required String address,
    String? paymentMethodId,
    String? addressId,
    String? instructions,
  }) async {
    _recordCall('createOrder');

    if (items.isEmpty) {
      throw const ApiException('Cannot place order with empty cart.', statusCode: 400);
    }

    int computedTotalCents = 0;
    final orderItems = <Map<String, dynamic>>[];

    for (final item in items) {
      final String prodId = item is Map ? item['productId'] as String : item.product.id as String;
      final int qty = item is Map ? (item['quantity'] as num).toInt() : item.quantity as int;
      final prod = _products.firstWhere((p) => p.id == prodId);
      final itemTotal = prod.priceCents * qty;
      computedTotalCents += itemTotal;

      orderItems.add({
        'productId': prod.id,
        'name': prod.name,
        'quantity': qty,
        'priceCents': prod.priceCents,
        'lineTotalCents': itemTotal,
      });
    }

    // Taxes and packaging calculations
    final deliveryCents = computedTotalCents >= 19900 ? 0 : 2500;
    final packagingCents = 1000;
    final taxCents = (computedTotalCents * 0.05).round();
    final grandTotalCents = computedTotalCents + deliveryCents + packagingCents + taxCents;

    // If paid via QwikWallet, deduct balance
    if (paymentMethodId == 'qwik_wallet') {
      if (_wallet.balanceCents < grandTotalCents) {
        throw ApiException(
          'Insufficient wallet balance. Required: ₹${(grandTotalCents / 100).toStringAsFixed(2)}, Available: ₹${(_wallet.balanceCents / 100).toStringAsFixed(2)}',
          statusCode: 402,
        );
      }
      final newBalance = _wallet.balanceCents - grandTotalCents;
      final tx = WalletTransaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: 'debit',
        amountCents: grandTotalCents,
        balanceAfterCents: newBalance,
        note: 'Payment for order',
        createdAt: DateTime.now(),
      );
      _wallet = WalletSummary(
        balanceCents: newBalance,
        transactions: List.of(_wallet.transactions)..insert(0, tx),
      );
    }

    final newOrder = GroceryOrder(
      id: 'ORD-${1000 + _orders.length + 1}',
      status: 'placed',
      totalCents: grandTotalCents,
      createdAt: DateTime.now(),
      address: address,
      items: orderItems,
      delivery: {
        'partnerName': 'Suresh Patel',
        'partnerPhone': '9876540987',
        'etaMinutes': 12,
        'instructions': instructions ?? '',
      },
      deliveryLocation: {'latitude': 12.9716, 'longitude': 77.5946},
    );

    _orders.insert(0, newOrder);
    return newOrder;
  }

  /// Staff order list.
  Future<List<GroceryOrder>> staffOrders() async {
    _recordCall('staffOrders');
    return List.unmodifiable(_orders);
  }

  /// Sets order status (`placed` -> `preparing` -> `out_for_delivery` -> `delivered`).
  Future<GroceryOrder> setOrderStatus(String id, String status) async {
    _recordCall('setOrderStatus');
    final index = _orders.indexWhere((o) => o.id == id);
    if (index == -1) {
      throw ApiException('Order not found: $id', statusCode: 404);
    }

    final current = _orders[index];
    final updated = GroceryOrder(
      id: current.id,
      status: status,
      totalCents: current.totalCents,
      createdAt: current.createdAt,
      address: current.address,
      items: current.items,
      delivery: current.delivery,
      deliveryLocation: current.deliveryLocation,
    );

    _orders[index] = updated;
    return updated;
  }

  /// Fetches current wallet balance and transactions.
  Future<WalletSummary> wallet() async {
    _recordCall('wallet');
    return _wallet;
  }

  /// Tops up wallet balance.
  Future<void> topUpWallet(int amountCents) async {
    _recordCall('topUpWallet');
    if (amountCents <= 0) {
      throw const ApiException('Top-up amount must be greater than zero.', statusCode: 400);
    }
    final newBalance = _wallet.balanceCents + amountCents;
    final tx = WalletTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      type: 'credit',
      amountCents: amountCents,
      balanceAfterCents: newBalance,
      note: 'Wallet balance top-up',
      createdAt: DateTime.now(),
    );

    _wallet = WalletSummary(
      balanceCents: newBalance,
      transactions: List.of(_wallet.transactions)..insert(0, tx),
    );
  }

  /// Fetches recurring subscriptions.
  Future<List<GrocerySubscription>> subscriptions() async {
    _recordCall('subscriptions');
    return List.unmodifiable(_subscriptions);
  }

  /// Creates or updates a recurring subscription.
  Future<GrocerySubscription> saveSubscription({
    String? id,
    required List<Map<String, dynamic>> items,
    required String addressId,
    required String frequency,
    required DateTime startDate,
    required String deliveryTime,
  }) async {
    _recordCall('saveSubscription');
    final matchedAddr = _profile.addresses.firstWhere(
      (a) => a.id == addressId,
      orElse: () => TestFixtures.addrHome,
    );

    final subItems = items.map((raw) {
      final prodId = raw['productId'] as String;
      final qty = (raw['quantity'] as num).toInt();
      final prod = _products.firstWhere((p) => p.id == prodId);
      return ScheduledItem(
        productId: prod.id,
        productName: prod.name,
        quantity: qty,
        unitPriceCents: prod.priceCents,
      );
    }).toList();

    final newSub = GrocerySubscription(
      id: id ?? 'sub_${DateTime.now().millisecondsSinceEpoch}',
      active: true,
      frequency: frequency,
      deliveryTime: deliveryTime,
      startDate: startDate,
      nextRunAt: startDate.add(const Duration(days: 1)),
      address: matchedAddr.formatted,
      addressId: matchedAddr.id,
      items: subItems,
    );

    if (id != null) {
      final idx = _subscriptions.indexWhere((s) => s.id == id);
      if (idx != -1) {
        _subscriptions[idx] = newSub;
        return newSub;
      }
    }

    _subscriptions.add(newSub);
    return newSub;
  }

  /// Toggles subscription active/paused state.
  Future<void> setSubscriptionActive(String id, bool active) async {
    _recordCall('setSubscriptionActive');
    final idx = _subscriptions.indexWhere((s) => s.id == id);
    if (idx != -1) {
      final s = _subscriptions[idx];
      _subscriptions[idx] = GrocerySubscription(
        id: s.id,
        active: active,
        frequency: s.frequency,
        deliveryTime: s.deliveryTime,
        startDate: s.startDate,
        nextRunAt: s.nextRunAt,
        address: s.address,
        addressId: s.addressId,
        items: s.items,
      );
    }
  }
}
