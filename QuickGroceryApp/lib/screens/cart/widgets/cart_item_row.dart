import 'package:flutter/material.dart';

import '../../../components/quantity_stepper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/cart_item.dart';
import '../../../state/cart_controller.dart';

class CartItemRow extends StatelessWidget {
  const CartItemRow({super.key, required this.item, required this.cart});
  final CartItem item;
  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 68,
                height: 68,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceContainerLow,
                          child: const Icon(
                            Icons.local_grocery_store_outlined,
                            color: AppColors.emeraldPrimary,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceContainerLow,
                        child: const Icon(
                          Icons.local_grocery_store_outlined,
                          color: AppColors.emeraldPrimary,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.displayUnit,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '₹${(product.priceCents / 100).toStringAsFixed(0)} each',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '₹${(item.totalCents / 100).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                QuantityStepper(product: product, compact: true),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => cart.remove(product.id),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
