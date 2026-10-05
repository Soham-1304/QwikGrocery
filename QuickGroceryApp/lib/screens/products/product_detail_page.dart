import 'package:flutter/material.dart';

import '../../components/delivery_widgets.dart';
import '../../components/quantity_stepper.dart';
import '../../core/theme/app_colors.dart';
import '../../models/product.dart';
import 'widgets/product_accordions.dart';
import 'widgets/product_image_gallery.dart';

/// Richly detailed product page: image gallery, freshness badges,
/// price section, accordion details, and sticky add-to-cart bar.
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _imgIndex = 0;
  final _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final images = p.allImages.isNotEmpty ? p.allImages : <String>[];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ProductImageGallery(
                  images: images,
                  imageUrl: p.imageUrl,
                  index: _imgIndex,
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _imgIndex = i),
                ),
                _DiscountBadge(product: p),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (p.brand.isNotEmpty)
                        Text(
                          p.brand.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.emeraldPrimary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        p.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.displayUnit,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PriceRow(product: p),
                      const SizedBox(height: 16),
                      const DeliveryEtaPill(),
                      if (p.description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          p.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.55,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _FreshnessBadges(badges: p.freshnessBadges),
                      const SizedBox(height: 16),
                      if (p.nutritionalInfo.isNotEmpty)
                        ProductAccordions(
                          title: 'Nutritional Information',
                          icon: Icons.receipt_long_outlined,
                          child: NutritionTable(info: p.nutritionalInfo),
                        ),
                      if (p.storageInstructions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ProductAccordions(
                          title: 'Storage & Shelf Life',
                          icon: Icons.inventory_2_outlined,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              p.storageInstructions,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _StickyActionBar(product: p),
        ],
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    if (!product.hasDiscount) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: AppColors.emeraldLight,
      child: Text(
        '🎉 ${product.discountPercentage}% OFF · You save ₹${product.savings.toStringAsFixed(0)}',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.emeraldDark,
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        '₹${(product.priceCents / 100).toStringAsFixed(0)}',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),
      if (product.hasDiscount) ...[
        const SizedBox(width: 10),
        Text(
          'MRP ₹${(product.effectiveMrpCents / 100).toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textTertiary,
            decoration: TextDecoration.lineThrough,
          ),
        ),
      ],
    ],
  );
}

class _FreshnessBadges extends StatelessWidget {
  const _FreshnessBadges({required this.badges});
  final List<String> badges;

  static const _defaults = [
    '✓ Quality Guaranteed',
    '✓ Farm Fresh',
    '✓ Cold Chain',
  ];

  @override
  Widget build(BuildContext context) {
    final items = badges.isNotEmpty ? badges : _defaults;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((badge) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.emeraldLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.emeraldPrimary.withAlpha(60)),
        ),
        child: Text(
          badge,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.emeraldDark,
          ),
        ),
      )).toList(),
    );
  }
}

class _StickyActionBar extends StatelessWidget {
  const _StickyActionBar({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₹${(product.priceCents / 100).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (product.hasDiscount)
                  Text(
                    '${product.discountPercentage}% off',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.emeraldPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 44,
              child: QuantityStepper(
                product: product,
                compact: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
