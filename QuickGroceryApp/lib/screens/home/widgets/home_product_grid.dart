import 'package:flutter/material.dart';

import '../../../components/product_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/product.dart';

/// Responsive product grid sliver with error & empty state handling.
class HomeProductGrid extends StatelessWidget {
  const HomeProductGrid({
    super.key,
    required this.productsFuture,
    required this.selectedCategory,
    required this.onRetry,
    required this.onTap,
  });

  final Future<List<Product>> productsFuture;
  final String selectedCategory;
  final VoidCallback onRetry;
  final ValueChanged<Product> onTap;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: FutureBuilder<List<Product>>(
        future: productsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          if (snap.hasError) {
            return SliverToBoxAdapter(
              child: _ErrorState(onRetry: onRetry),
            );
          }
          var products = snap.data ?? [];
          if (selectedCategory.isNotEmpty) {
            products = products
                .where((p) => p.category == selectedCategory)
                .toList();
          }
          final preview = products.take(12).toList();
          if (preview.isEmpty) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No products available right now.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            );
          }
          return SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => ProductCard(
                product: preview[i],
                onTap: () => onTap(preview[i]),
              ),
              childCount: preview.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _columns(MediaQuery.sizeOf(ctx).width),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
          );
        },
      ),
    );
  }

  int _columns(double width) {
    if (width > 1100) return 5;
    if (width > 800) return 4;
    if (width > 550) return 3;
    return 2;
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.cloud_off_outlined,
          size: 40,
          color: AppColors.textTertiary,
        ),
        const SizedBox(height: 12),
        const Text(
          'Couldn\'t load products',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Try again'),
        ),
      ],
    ),
  );
}
