import 'dart:async';

import 'package:flutter/material.dart';

import '../../components/product_card.dart';
import '../../core/theme/app_colors.dart';
import '../../models/product.dart';
import '../../services/api_client.dart';
import '../../state/cart_controller.dart';
import '../../state/cart_scope.dart';
import '../products/product_detail_page.dart';
import 'widgets/catalog_filter_bar.dart';
import 'widgets/catalog_sort_sheet.dart';

/// Blinkit-style product catalog with sticky search, category chips, sort sheet.
class CatalogPage extends StatefulWidget {
  const CatalogPage({
    super.key,
    required this.api,
    required this.cart,
    this.initialCategory = '',
  });
  final ApiClient api;
  final CartController cart;
  final String initialCategory;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _search = TextEditingController();
  Timer? _debounce;
  late String _category;
  bool _availableOnly = false;
  SortOrder _sort = SortOrder.none;
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

  Future<List<Product>> _load() => widget.api.products(
    search: _search.text.trim(),
    category: _category,
    available: _availableOnly ? true : null,
  );

  void _refresh() => setState(() => _products = _load());

  void _onSearch(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), _refresh);
  }

  Future<void> _showSortSheet() async {
    final picked = await showModalBottomSheet<SortOrder>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CatalogSortSheet(current: _sort),
    );
    if (picked != null && picked != _sort) {
      setState(() => _sort = picked);
    }
  }

  List<Product> _sorted(List<Product> products) {
    final list = [...products];
    switch (_sort) {
      case SortOrder.priceLow:
        list.sort((a, b) => a.priceCents.compareTo(b.priceCents));
      case SortOrder.priceHigh:
        list.sort((a, b) => b.priceCents.compareTo(a.priceCents));
      case SortOrder.discount:
        list.sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
      case SortOrder.none:
        break;
    }
    return list;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CartScope(
      controller: widget.cart,
      child: Column(
        children: [
          CatalogFilterBar(
            searchController: _search,
            onSearchChanged: _onSearch,
            onSortTap: _showSortSheet,
            sortActive: _sort != SortOrder.none,
            categoriesFuture: _categories,
            selectedCategory: _category,
            availableOnly: _availableOnly,
            onCategoryChanged: (cat) => setState(() {
              _category = cat;
              _products = _load();
            }),
            onAvailableToggle: (val) => setState(() {
              _availableOnly = val;
              _products = _load();
            }),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _products,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting &&
                    !snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_outlined,
                          size: 40,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 12),
                        const Text('Couldn\'t load catalog'),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try again'),
                        ),
                      ],
                    ),
                  );
                }
                final products = _sorted(snap.data ?? []);
                if (products.isEmpty) {
                  return const _EmptyResults();
                }
                return _ProductGrid(
                  products: products,
                  cart: widget.cart,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.products,
    required this.cart,
  });
  final List<Product> products;
  final CartController cart;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _cols(MediaQuery.sizeOf(context).width),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (ctx, i) => ProductCard(
        product: products[i],
        onTap: () => Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => CartScope(
              controller: cart,
              child: ProductDetailPage(product: products[i]),
            ),
          ),
        ),
      ),
    );
  }

  int _cols(double width) {
    if (width > 1100) return 5;
    if (width > 800) return 4;
    if (width > 550) return 3;
    return 2;
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.search_off_rounded,
          size: 48,
          color: AppColors.textTertiary,
        ),
        const SizedBox(height: 14),
        const Text(
          'No matching groceries',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 6),
        const Text(
          'Try another search or clear a filter.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}
