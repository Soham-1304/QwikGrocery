import 'package:flutter/material.dart';

import '../../components/category_rail.dart';
import '../../components/deals_carousel.dart';
import '../../components/delivery_widgets.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/banner_item.dart';
import '../../models/customer_profile.dart';
import '../../models/product.dart';
import '../../services/api_client.dart';
import '../../state/cart_controller.dart';
import '../../state/cart_scope.dart';
import '../products/product_detail_page.dart';
import 'widgets/home_product_grid.dart';

/// Blinkit-style grocery dashboard: ETA pill, promo carousel, category rail, and product grid.
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.api,
    required this.cart,
    required this.onBrowse,
  });
  final ApiClient api;
  final CartController cart;
  final void Function([String? category]) onBrowse;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Product>> _products;
  late Future<CustomerProfile> _profile;
  String _selectedCategory = '';

  static final _banners = [
    const BannerItem(
      id: 'fresh',
      title: 'Farm Fresh\nVegetables',
      subtitle: 'Delivered in 10-15 mins',
      tag: '🌿 ORGANIC',
      primaryColor: Color(0xFF1B5E20),
      secondaryColor: Color(0xFF388E3C),
      icon: Icons.eco_outlined,
      categoryFilter: 'Vegetables',
    ),
    const BannerItem(
      id: 'dairy',
      title: 'Fresh Dairy,\nEvery Morning',
      subtitle: 'Milk, curd & more',
      tag: '🥛 FRESH',
      primaryColor: Color(0xFF0D47A1),
      secondaryColor: Color(0xFF1976D2),
      icon: Icons.water_drop_outlined,
      categoryFilter: 'Dairy',
    ),
    const BannerItem(
      id: 'snacks',
      title: 'Snack Time\nSorted!',
      subtitle: 'Biscuits, chips & beverages',
      tag: '🍪 TRENDING',
      primaryColor: Color(0xFF4A148C),
      secondaryColor: Color(0xFF7B1FA2),
      icon: Icons.cookie_outlined,
      categoryFilter: 'Snacks',
    ),
    const BannerItem(
      id: 'fruits',
      title: 'Sweet Seasonal\nFruits',
      subtitle: 'Quality guaranteed',
      tag: '🍎 SEASONAL',
      primaryColor: Color(0xFFBF360C),
      secondaryColor: Color(0xFFE64A19),
      icon: Icons.apple,
      categoryFilter: 'Fruits',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _products = widget.api.products(available: true);
    _profile = widget.api.profile();
  }

  void _reload() => setState(() {
    _products = widget.api.products(available: true);
    _profile = widget.api.profile();
  });

  void _onCategorySelect(String cat) {
    setState(() => _selectedCategory = cat);
  }

  void _goToProduct(BuildContext ctx, Product product) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => CartScope(
          controller: widget.cart,
          child: ProductDetailPage(product: product),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CartScope(
      controller: widget.cart,
      child: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: CustomScrollView(
          slivers: [
            _SliverHeader(
              etaText: AppConstants.deliveryEtaText,
              profileFuture: _profile,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: DealsCarousel(
                banners: _banners,
                onSelectCategory: (cat) => widget.onBrowse(cat),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SectionTitle(
                  title: 'Shop by Category',
                  onSeeAll: () => widget.onBrowse(),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: FutureBuilder<List<Product>>(
                future: _products,
                builder: (ctx, snap) {
                  final categories = (snap.data ?? [])
                      .map((p) => p.category)
                      .toSet()
                      .toList()
                    ..sort();
                  if (categories.isEmpty) return const SizedBox.shrink();
                  return CategoryRail(
                    categories: categories,
                    selected: _selectedCategory,
                    onSelect: _onCategorySelect,
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SectionTitle(
                  title: _selectedCategory.isEmpty
                      ? 'Available Now'
                      : _selectedCategory,
                  onSeeAll: () => widget.onBrowse(_selectedCategory),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            HomeProductGrid(
              productsFuture: _products,
              selectedCategory: _selectedCategory,
              onRetry: _reload,
              onTap: (p) => _goToProduct(context, p),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _SliverHeader extends StatelessWidget {
  const _SliverHeader({
    required this.etaText,
    required this.profileFuture,
  });

  final String etaText;
  final Future<CustomerProfile> profileFuture;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: FutureBuilder<CustomerProfile>(
        future: profileFuture,
        builder: (context, snapshot) {
          final addresses = snapshot.data?.addresses ?? [];
          final firstAddress = addresses.isNotEmpty ? addresses.first : null;
          final locationTitle = firstAddress != null
              ? (firstAddress.line1.isNotEmpty
                  ? firstAddress.line1
                  : (firstAddress.label.isNotEmpty ? firstAddress.label : 'Home'))
              : 'Your Location';
          final locationSubtitle = firstAddress != null
              ? ([
                  firstAddress.line2,
                  firstAddress.landmark,
                  firstAddress.city,
                  firstAddress.postalCode,
                ].where((s) => s.trim().isNotEmpty).join(', ').isNotEmpty
                    ? [
                        firstAddress.line2,
                        firstAddress.landmark,
                        firstAddress.city,
                        firstAddress.postalCode,
                      ].where((s) => s.trim().isNotEmpty).join(', ')
                    : (firstAddress.formatted.isNotEmpty
                        ? firstAddress.formatted
                        : 'Saved address'))
              : 'Add address to order';

          return Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 20,
                color: AppColors.emeraldPrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            locationTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                    Text(
                      locationSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              DeliveryEtaPill(etaText: etaText),
            ],
          );
        },
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      const Spacer(),
      TextButton(
        onPressed: onSeeAll,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'See all',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.emeraldPrimary,
          ),
        ),
      ),
    ],
  );
}
