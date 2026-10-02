import 'product.dart';

class CartLine {
  const CartLine({required this.product, required this.quantity});
  final Product product;
  final int quantity;
  int get totalCents => product.priceCents * quantity;
  CartLine withQuantity(int value) =>
      CartLine(product: product, quantity: value);
}
