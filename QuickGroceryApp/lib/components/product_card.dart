import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/product.dart';
import '../state/cart_scope.dart';
import 'quantity_stepper.dart';

/// Blinkit-style product card with image, brand/name/weight, price + discount
/// badge, and in-card quantity stepper.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImage(product: product),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _UnitLabel(unit: product.displayUnit),
                        const SizedBox(height: 2),
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: _PriceSection(product: product)),
                        ValueListenableBuilder<int>(
                          valueListenable: _CartQtyNotifier(context, product.id),
                          builder: (_, __, ___) => QuantityStepper(
                            product: product,
                            compact: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1.05,
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _ImageFallback(),
                  )
                : const _ImageFallback(),
          ),
          if (product.hasDiscount)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.emeraldPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${product.discountPercentage}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          if (!product.available)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(160),
                ),
                child: const Center(
                  child: Text(
                    'Out of stock',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surfaceContainerLow,
    child: const Center(
      child: Icon(
        Icons.local_grocery_store_outlined,
        color: AppColors.emeraldPrimary,
        size: 32,
      ),
    ),
  );
}

class _UnitLabel extends StatelessWidget {
  const _UnitLabel({required this.unit});
  final String unit;

  @override
  Widget build(BuildContext context) => Text(
    unit,
    style: const TextStyle(
      fontSize: 11,
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
    ),
  );
}

class _PriceSection extends StatelessWidget {
  const _PriceSection({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '₹${(product.priceCents / 100).toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        if (product.hasDiscount)
          Text(
            '₹${(product.effectiveMrpCents / 100).toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}

/// Lightweight notifier that bridges CartScope into a ValueListenable.
class _CartQtyNotifier extends ValueNotifier<int> {
  _CartQtyNotifier(BuildContext context, this.productId)
      : super(CartScope.of(context).quantityOf(productId));
  final String productId;
}
