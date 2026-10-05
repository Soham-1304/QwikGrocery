import 'product.dart';

/// Represents a single product entry with quantity in the shopping cart.
class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
  });

  final Product product;
  final int quantity;

  double get lineTotal => (product.priceCents * quantity) / 100.0;
  double get lineMrpTotal => (product.effectiveMrpCents * quantity) / 100.0;
  double get lineSavings =>
      lineMrpTotal > lineTotal ? lineMrpTotal - lineTotal : 0.0;
  int get totalCents => product.priceCents * quantity;
  int get totalMrpCents => product.effectiveMrpCents * quantity;

  CartItem copyWith({Product? product, int? quantity}) => CartItem(
    product: product ?? this.product,
    quantity: quantity ?? this.quantity,
  );

  CartItem withQuantity(int value) => copyWith(quantity: value);

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: Product.fromJson(json['product'] as Map<String, dynamic>),
    quantity: (json['quantity'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
  };
}
