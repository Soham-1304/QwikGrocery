part of '../../ui.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key, required this.api, required this.cart});
  final ApiClient api;
  final CartStore cart;
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Your cart')),
    body: AnimatedBuilder(
      animation: widget.cart,
      builder: (context, _) {
        final items = widget.cart.items;
        if (items.isEmpty) {
          return _EmptyState(
            icon: Icons.shopping_basket_outlined,
            title: 'Your cart is empty',
            detail: 'Browse the catalog to add groceries.',
            action: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue shopping'),
            ),
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ...items.map(
                  (line) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: ProductImage(url: line.product.imageUrl),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(money(line.product.priceCents)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => widget.cart.setQuantity(
                                        line,
                                        line.quantity - 1,
                                      ),
                                      icon: const Icon(Icons.remove),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    Text('${line.quantity}'),
                                    IconButton(
                                      onPressed: () => widget.cart.setQuantity(
                                        line,
                                        line.quantity + 1,
                                      ),
                                      icon: const Icon(Icons.add),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Line total ${money(line.totalCents)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                widget.cart.remove(line.product.id),
                            tooltip: 'Remove ${line.product.name}',
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _MoneyRow(
                          label: 'Subtotal',
                          cents: widget.cart.subtotalCents,
                        ),
                        const Divider(height: 24),
                        _MoneyRow(
                          label: 'Total',
                          cents: widget.cart.subtotalCents,
                          bold: true,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutPage(
                                  api: widget.api,
                                  cart: widget.cart,
                                ),
                              ),
                            ),
                            child: const Text('Continue to checkout'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
