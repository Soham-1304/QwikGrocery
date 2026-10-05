import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/bill_summary.dart';
import '../models/cart_line.dart';
import '../models/product.dart';

/// Central reactive controller managing shopping cart items, line calculations,
/// MRP savings, and free delivery threshold math.
class CartController extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  /// Unmodifiable view of cart items keyed by product ID.
  Map<String, CartItem> get items => Map.unmodifiable(_items);

  /// List of current cart items.
  List<CartItem> get itemsList => _items.values.toList(growable: false);

  /// List of CartLine instances for API compatibility.
  List<CartLine> get cartLines => _items.values
      .map((item) => CartLine(product: item.product, quantity: item.quantity))
      .toList(growable: false);

  /// Number of distinct products in cart.
  int get itemCount => _items.length;

  /// Total count of all items across all products.
  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  /// Alias for backward compatibility with older CartStore.
  int get count => totalQuantity;

  /// Cart subtotal in rupees based on actual selling price.
  double get subtotal =>
      _items.values.fold(0.0, (sum, item) => sum + item.lineTotal);

  /// Subtotal in cents for backward compatibility.
  int get subtotalCents => (subtotal * 100).round();

  /// Total MRP value before discounts.
  double get mrpTotal =>
      _items.values.fold(0.0, (sum, item) => sum + item.lineMrpTotal);

  /// Total savings compared to MRP.
  double get mrpSavings =>
      mrpTotal > subtotal ? mrpTotal - subtotal : 0.0;

  /// Minimum order subtotal required to qualify for free delivery (₹199).
  double get freeDeliveryThreshold => AppConstants.freeDeliveryThreshold;

  /// Whether current cart qualifies for free delivery.
  bool get hasFreeDelivery => subtotal >= freeDeliveryThreshold;

  /// Delivery fee (₹0 if free delivery or empty cart, else ₹25).
  double get deliveryFee =>
      _items.isEmpty ? 0.0 : (hasFreeDelivery ? 0.0 : AppConstants.standardDeliveryFee);

  /// Fixed packaging and handling charge (₹0 if empty cart, else ₹10).
  double get packagingCharge =>
      _items.isEmpty ? 0.0 : AppConstants.packagingCharge;

  /// Taxes calculated as 5% of subtotal.
  double get taxes => subtotal * AppConstants.taxRate;

  /// Final payable amount including items, delivery, packaging, and taxes.
  double get total =>
      _items.isEmpty ? 0.0 : (subtotal + deliveryFee + packagingCharge + taxes);

  /// Remaining amount needed in rupees to unlock free delivery.
  double get amountNeededForFreeDelivery =>
      hasFreeDelivery ? 0.0 : (freeDeliveryThreshold - subtotal);

  /// Normalized progress (0.0 to 1.0) towards free delivery.
  double get freeDeliveryProgress =>
      (subtotal / freeDeliveryThreshold).clamp(0.0, 1.0);

  /// Returns current quantity of specified product in cart (O(1)).
  int quantityOf(String productId) => _items[productId]?.quantity ?? 0;

  /// Alias for quantityOf.
  int quantityFor(String productId) => quantityOf(productId);

  /// Adds a product to the cart with specified quantity, clamped to stock.
  void add(Product product, {int quantity = 1}) {
    if (product.stock <= 0 || quantity <= 0) return;
    final current = _items[product.id]?.quantity ?? 0;
    final next = (current + quantity).clamp(1, product.stock);
    _items[product.id] = CartItem(product: product, quantity: next);
    notifyListeners();
  }

  /// Increments quantity of product by 1.
  void increment(Product product) => add(product, quantity: 1);

  /// Decrements quantity of product by 1, removing it if quantity drops to 0.
  void decrement(String productId) {
    final existing = _items[productId];
    if (existing == null) return;
    if (existing.quantity <= 1) {
      _items.remove(productId);
    } else {
      _items[productId] = existing.copyWith(quantity: existing.quantity - 1);
    }
    notifyListeners();
  }

  /// Explicitly sets quantity of a product in cart.
  void setQuantity(String productId, int quantity) {
    final existing = _items[productId];
    if (existing == null) return;
    if (quantity <= 0) {
      _items.remove(productId);
    } else {
      final clamped = quantity.clamp(1, existing.product.stock);
      _items[productId] = existing.copyWith(quantity: clamped);
    }
    notifyListeners();
  }

  /// Removes an item completely from cart.
  void remove(String productId) {
    if (_items.remove(productId) != null) {
      notifyListeners();
    }
  }

  /// Clears all items from cart.
  void clear() {
    if (_items.isNotEmpty) {
      _items.clear();
      notifyListeners();
    }
  }

  /// Generates an immutable [BillSummary] snapshot from the current cart state.
  BillSummary toBillSummary() => BillSummary(
    itemTotal: subtotal,
    mrpTotal: mrpTotal,
    mrpSavings: mrpSavings,
    deliveryFee: deliveryFee,
    packagingCharge: packagingCharge,
    taxes: taxes,
    total: total,
    freeDeliveryThreshold: freeDeliveryThreshold,
    amountNeededForFreeDelivery: amountNeededForFreeDelivery,
  );
}
