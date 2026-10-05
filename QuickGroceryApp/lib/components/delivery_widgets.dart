import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../state/cart_scope.dart';

/// Floating pill showing delivery ETA and animated cart total.
class DeliveryEtaPill extends StatelessWidget {
  const DeliveryEtaPill({super.key, this.etaText = '⚡ Delivery in 10-15 mins'});
  final String etaText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.emeraldLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.emeraldPrimary.withAlpha(40)),
      ),
      child: Text(
        etaText,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.emeraldDark,
        ),
      ),
    );
  }
}

/// Free delivery progress meter for cart/checkout screens.
class DeliveryMeter extends StatelessWidget {
  const DeliveryMeter({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    if (cart.itemCount == 0) return const SizedBox.shrink();

    if (cart.hasFreeDelivery) {
      return _MeterBanner(
        color: AppColors.emeraldPrimary,
        icon: Icons.local_shipping_outlined,
        message: '🎉 You\'ve unlocked FREE delivery!',
      );
    }

    final needed = cart.amountNeededForFreeDelivery;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add ₹${needed.toStringAsFixed(0)} more for FREE Delivery',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: cart.freeDeliveryProgress,
            minHeight: 5,
            backgroundColor: AppColors.outline,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.emeraldPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _MeterBanner extends StatelessWidget {
  const _MeterBanner({
    required this.color,
    required this.icon,
    required this.message,
  });
  final Color color;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.emeraldLight,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          message,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}
