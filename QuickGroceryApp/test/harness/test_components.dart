import 'package:flutter/material.dart';
import 'package:qwik_grocery_app/core/theme/app_colors.dart';
import 'package:qwik_grocery_app/core/utils/currency_formatter.dart';
import 'package:qwik_grocery_app/models/banner_item.dart';
import 'package:qwik_grocery_app/models/bill_summary.dart';
import 'package:qwik_grocery_app/models/category.dart';
import 'package:qwik_grocery_app/models/product.dart';
import 'package:qwik_grocery_app/state/cart_controller.dart';
import 'package:qwik_grocery_app/state/cart_scope.dart';

/// Reusable Blinkit-tier Delivery ETA Pill widget.
class DeliveryEtaPill extends StatelessWidget {
  const DeliveryEtaPill({
    super.key,
    this.etaText = '⚡ Delivery in 10-15 mins',
    this.compact = false,
  });

  final String etaText;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('delivery_eta_pill'),
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.paleGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.emeraldPrimary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flash_on, size: 14, color: AppColors.emeraldPrimary),
          const SizedBox(width: 4),
          Text(
            etaText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.emeraldDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dynamic Free Delivery Progress Meter.
class DeliveryMeter extends StatelessWidget {
  const DeliveryMeter({
    super.key,
    this.compact = false,
    this.controller,
  });

  final bool compact;
  final CartController? controller;

  @override
  Widget build(BuildContext context) {
    final cart = controller ?? CartScope.of(context);
    final hasFree = cart.hasFreeDelivery;
    final progress = cart.freeDeliveryProgress;
    final needed = cart.amountNeededForFreeDelivery;

    final message = hasFree
        ? 'You unlocked FREE Delivery!'
        : 'Add ${CurrencyFormatter.formatRupees(needed)} more for FREE Delivery!';

    return Container(
      key: const Key('delivery_meter'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasFree ? AppColors.paleGreen : AppColors.paleYellow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFree ? AppColors.emeraldPrimary : AppColors.warmYellowDark,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasFree ? Icons.check_circle : Icons.local_shipping,
                size: 16,
                color: hasFree ? AppColors.emeraldPrimary : AppColors.warmYellowDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasFree ? AppColors.emeraldDark : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(
              hasFree ? AppColors.emeraldPrimary : AppColors.warmYellow,
            ),
          ),
        ],
      ),
    );
  }
}

/// In-Card Quantity Stepper (- [ qty ] +)
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.product,
    this.compact = false,
    this.elevation = 0.0,
    this.controller,
    this.onIncrement,
    this.onDecrement,
  });

  final Product product;
  final bool compact;
  final double elevation;
  final CartController? controller;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final cart = controller ?? CartScope.maybeOf(context);
    final qty = cart?.quantityOf(product.id) ?? 0;
    final isMaxStock = qty >= product.stock;

    return Container(
      key: Key('stepper_${product.id}'),
      height: compact ? 30 : 36,
      decoration: BoxDecoration(
        color: AppColors.emeraldPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: Key('stepper_decrement_${product.id}'),
            padding: EdgeInsets.zero,
            iconSize: compact ? 16 : 18,
            icon: const Icon(Icons.remove, color: Colors.white),
            onPressed: () {
              if (onDecrement != null) {
                onDecrement!();
              } else {
                cart?.decrement(product.id);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$qty',
              key: Key('stepper_count_${product.id}'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            key: Key('stepper_increment_${product.id}'),
            padding: EdgeInsets.zero,
            iconSize: compact ? 16 : 18,
            icon: Icon(
              Icons.add,
              color: isMaxStock ? Colors.white.withOpacity(0.4) : Colors.white,
            ),
            onPressed: isMaxStock
                ? null
                : () {
                    if (onIncrement != null) {
                      onIncrement!();
                    } else {
                      cart?.increment(product);
                    }
                  },
          ),
        ],
      ),
    );
  }
}

/// Modern Blinkit-Style Product Card.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onProductTap,
    this.compact = false,
    this.controller,
  });

  final Product product;
  final VoidCallback? onProductTap;
  final bool compact;
  final CartController? controller;

  @override
  Widget build(BuildContext context) {
    final cart = controller ?? CartScope.maybeOf(context);
    final qty = cart?.quantityOf(product.id) ?? 0;
    final isOutOfStock = !product.available;

    return Card(
      key: Key('product_card_${product.id}'),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: onProductTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with discount pill
              Stack(
                children: [
                  Container(
                    height: compact ? 80 : 110,
                    width: double.infinity,
                    color: AppColors.surfaceContainerLow,
                    child: Center(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldPrimary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${product.discountPercentage}% OFF',
                          key: Key('discount_pill_${product.id}'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              // Brand Tag
              if (product.brand.isNotEmpty)
                Text(
                  product.brand.toUpperCase(),
                  key: Key('brand_tag_${product.id}'),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
              // Product Name
              Text(
                product.name,
                key: Key('product_name_${product.id}'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              // Pack size
              Text(
                product.displayUnit,
                key: Key('pack_unit_${product.id}'),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              // Price and In-Card Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CurrencyFormatter.formatRupees(product.price),
                        key: Key('price_${product.id}'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (product.hasDiscount)
                        Text(
                          CurrencyFormatter.formatRupees(product.mrp),
                          key: Key('mrp_${product.id}'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  if (isOutOfStock)
                    Container(
                      key: Key('out_of_stock_${product.id}'),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Out of stock',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    )
                  else if (qty == 0)
                    ElevatedButton(
                      key: Key('btn_add_${product.id}'),
                      onPressed: () => cart?.add(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.emeraldPrimary,
                        side: const BorderSide(color: AppColors.emeraldPrimary, width: 1.5),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      ),
                      child: const Text('+ ADD', style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  else
                    QuantityStepper(
                      product: product,
                      controller: cart,
                      compact: true,
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

/// Deals Hero Promo Carousel.
class DealsCarousel extends StatefulWidget {
  const DealsCarousel({
    super.key,
    required this.banners,
    this.onBannerTap,
  });

  final List<BannerItem> banners;
  final ValueChanged<BannerItem>? onBannerTap;

  @override
  State<DealsCarousel> createState() => _DealsCarouselState();
}

class _DealsCarouselState extends State<DealsCarousel> {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void selectIndex(int index) {
    if (widget.banners.isEmpty) return;
    setState(() {
      _currentIndex = index % widget.banners.length;
    });
  }

  void next() {
    if (widget.banners.isNotEmpty) {
      selectIndex(_currentIndex + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox(
        key: Key('deals_carousel_empty'),
        height: 120,
        child: Center(child: Text('No active promotions')),
      );
    }

    final banner = widget.banners[_currentIndex];

    return Container(
      key: const Key('deals_carousel'),
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.emeraldPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => widget.onBannerTap?.call(banner),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (banner.badgeText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warmYellow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    banner.badgeText,
                    key: const Key('banner_badge'),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                banner.title,
                key: const Key('banner_title'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                banner.subtitle,
                key: const Key('banner_subtitle'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              // Indicators
              Row(
                children: List.generate(
                  widget.banners.length,
                  (index) => Container(
                    key: Key('carousel_indicator_$index'),
                    width: index == _currentIndex ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: index == _currentIndex ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Visual Category Rail.
class CategoryRail extends StatelessWidget {
  const CategoryRail({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('category_rail'),
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat.id == selectedId || (selectedId == null && index == 0);

          return InkWell(
            key: Key('category_chip_${cat.id}'),
            onTap: () => onSelect(cat.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.emeraldPrimary : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.emeraldPrimary : AppColors.outline,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Freshness Guarantee Badge component.
class FreshnessBadge extends StatelessWidget {
  const FreshnessBadge({
    super.key,
    required this.badgeText,
  });

  final String badgeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('freshness_badge_${badgeText.replaceAll(' ', '_')}'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.paleGreen,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.emeraldLight, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 14, color: AppColors.emeraldPrimary),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.emeraldDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Transparent Bill Breakdown widget.
class BillBreakdown extends StatelessWidget {
  const BillBreakdown({
    super.key,
    required this.bill,
  });

  final BillSummary bill;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('bill_breakdown'),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bill Summary',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildRow('Item Total', CurrencyFormatter.formatRupees(bill.itemTotal), 'bill_item_total'),
            if (bill.mrpSavings > 0)
              _buildRow(
                'MRP Savings',
                '-${CurrencyFormatter.formatRupees(bill.mrpSavings)}',
                'bill_mrp_savings',
                color: AppColors.emeraldPrimary,
              ),
            _buildRow(
              'Delivery Fee',
              bill.deliveryFee == 0.0 ? 'FREE' : CurrencyFormatter.formatRupees(bill.deliveryFee),
              'bill_delivery_fee',
              color: bill.deliveryFee == 0.0 ? AppColors.emeraldPrimary : null,
            ),
            _buildRow('Packaging & Handling', CurrencyFormatter.formatRupees(bill.packagingCharge), 'bill_packaging_charge'),
            _buildRow('Taxes (5%)', CurrencyFormatter.formatRupees(bill.taxes), 'bill_taxes'),
            const Divider(),
            _buildRow(
              'Grand Total',
              CurrencyFormatter.formatRupees(bill.total),
              'bill_grand_total',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, String keyName, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            key: Key(keyName),
            style: TextStyle(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
