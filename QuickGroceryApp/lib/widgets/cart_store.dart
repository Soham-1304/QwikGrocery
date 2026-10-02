part of '../ui.dart';

class CartStore extends ChangeNotifier {
  final Map<String, CartLine> _items = {};
  List<CartLine> get items => _items.values.toList(growable: false);
  int get count => _items.values.fold(0, (sum, line) => sum + line.quantity);
  int get subtotalCents =>
      _items.values.fold(0, (sum, line) => sum + line.totalCents);

  void add(Product product, [int quantity = 1]) {
    final existing = _items[product.id]?.quantity ?? 0;
    final next = (existing + quantity).clamp(1, product.stock);
    if (product.stock > 0) {
      _items[product.id] = CartLine(product: product, quantity: next);
    }
    notifyListeners();
  }

  void setQuantity(CartLine line, int quantity) {
    if (quantity < 1) {
      _items.remove(line.product.id);
    } else if (quantity <= line.product.stock) {
      _items[line.product.id] = line.withQuantity(quantity);
    }
    notifyListeners();
  }

  void remove(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
