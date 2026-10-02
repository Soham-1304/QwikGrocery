part of '../../ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.api,
    required this.cart,
    required this.onBrowse,
  });
  final ApiClient api;
  final CartStore cart;
  final void Function([String? category]) onBrowse;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Product>> _products;
  @override
  void initState() {
    super.initState();
    _products = widget.api.products(available: true);
  }

  void _retry() =>
      setState(() => _products = widget.api.products(available: true));

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () async => _retry(),
    child: ListView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'THE WEEKLY SHOP',
                style: TextStyle(
                  color: _yellow,
                  letterSpacing: 1.1,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Good food,\nclose to home.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Find what you need and keep your next delivery on track.',
                style: TextStyle(color: Color(0xFFD8DFD8)),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => widget.onBrowse(),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Browse groceries'),
                style: FilledButton.styleFrom(
                  backgroundColor: _yellow,
                  foregroundColor: _black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available now',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () => widget.onBrowse(),
              child: const Text('See catalog'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Product>>(
          future: _products,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return _Problem(
                message: 'Products couldn’t load.',
                onRetry: _retry,
              );
            }
            final products = snapshot.data ?? [];
            if (products.isEmpty) {
              return const _EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No products available yet',
                detail: 'The catalog will appear here when products are added.',
              );
            }
            final categories = products.map((p) => p.category).toSet().toList()
              ..sort();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shop by category',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories
                      .map(
                        (category) => ActionChip(
                          label: Text(category),
                          onPressed: () => widget.onBrowse(category),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth > 1100
                        ? 4
                        : constraints.maxWidth > 700
                        ? 3
                        : constraints.maxWidth > 480
                        ? 2
                        : 1;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length > 8 ? 8 : products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: columns == 1 ? 2.2 : 0.78,
                      ),
                      itemBuilder: (_, i) => ProductCard(
                        product: products[i],
                        cart: widget.cart,
                        api: widget.api,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}
