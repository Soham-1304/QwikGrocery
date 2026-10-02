part of '../../ui.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.cart,
    required this.api,
  });
  final Product product;
  final CartStore cart;
  final ApiClient api;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailPage(product: product, cart: cart),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ProductImage(url: product.imageUrl)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.brand.isNotEmpty) ...[
                  Text(
                    product.brand.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _green,
                      fontSize: 10,
                      letterSpacing: .6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                ],
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  product.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        money(product.priceCents),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: product.available
                          ? () {
                              cart.add(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.name} added to cart',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.add, size: 19),
                      tooltip: product.available
                          ? 'Add ${product.name}'
                          : 'Out of stock',
                    ),
                  ],
                ),
                if (!product.available)
                  const Text(
                    'Out of stock',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.product,
    required this.cart,
  });
  final Product product;
  final CartStore cart;
  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      appBar: AppBar(title: const Text('Product details')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              SizedBox(height: 300, child: ProductImage(url: p.imageUrl)),
              const SizedBox(height: 24),
              Text(
                p.category.toUpperCase(),
                style: const TextStyle(
                  color: _green,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              if (p.brand.isNotEmpty) ...[
                Text(
                  p.brand,
                  style: const TextStyle(
                    color: _green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                p.name,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                money(p.priceCents),
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              Text(
                p.description.isEmpty
                    ? 'No product description is available.'
                    : p.description,
                style: const TextStyle(color: _muted, height: 1.5),
              ),
              if (p.aliases.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Also searched as: ${p.aliases.take(5).join(', ')}',
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                p.available ? '${p.stock} available' : 'Out of stock',
                style: TextStyle(
                  color: p.available ? _green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              if (p.available)
                Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      onPressed: _quantity < p.stock
                          ? () => setState(() => _quantity++)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: () {
                        widget.cart.add(p, _quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${p.name} added to cart')),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to cart'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
