part of '../../ui.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({
    super.key,
    required this.api,
    required this.cart,
    this.initialCategory = '',
  });
  final ApiClient api;
  final CartStore cart;
  final String initialCategory;
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _search = TextEditingController();
  Timer? _debounce;
  late String _category;
  bool _availableOnly = false;
  late Future<List<Product>> _products;
  late Future<List<String>> _categories;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _products = _load();
    _categories = widget.api.products().then(
      (items) => (items.map((p) => p.category).toSet().toList()..sort()),
    );
  }

  Future<List<Product>> _load() async {
    return widget.api.products(
      search: _search.text,
      category: _category,
      available: _availableOnly ? true : null,
    );
  }

  void _refresh() => setState(() => _products = _load());
  void _searchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), _refresh);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 330,
            child: TextField(
              controller: _search,
              onChanged: _searchChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search potato, batata, dhaniya…',
                isDense: true,
              ),
            ),
          ),
          FutureBuilder<List<String>>(
            future: _categories,
            builder: (context, snapshot) {
              final categories = snapshot.data ?? const <String>[];
              final selected =
                  _category.isEmpty || categories.contains(_category)
                  ? _category
                  : '';
              return DropdownButton<String>(
                value: selected,
                hint: const Text('Category'),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('All categories'),
                  ),
                  ...categories.map(
                    (c) => DropdownMenuItem(value: c, child: Text(c)),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _category = value ?? '';
                    _products = _load();
                  });
                },
              );
            },
          ),
          FilterChip(
            label: const Text('In stock'),
            selected: _availableOnly,
            onSelected: (value) {
              setState(() {
                _availableOnly = value;
                _products = _load();
              });
            },
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Text(
          'Regional names and common typos are supported.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _muted),
        ),
      ),
      const SizedBox(height: 20),
      FutureBuilder<List<Product>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return _Problem(
              message: 'Catalog couldn’t load.',
              onRetry: _refresh,
            );
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const _EmptyState(
              icon: Icons.search_off,
              title: 'No matching groceries',
              detail: 'Try another search or clear a filter.',
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 1050
                  ? 4
                  : constraints.maxWidth > 720
                  ? 3
                  : constraints.maxWidth > 430
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
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
          );
        },
      ),
    ],
  );
}
