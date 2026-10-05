import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../state/cart_controller.dart';

class CartBillCard extends StatelessWidget {
  const CartBillCard({super.key, required this.cart});
  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final bill = cart.toBillSummary();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bill Details',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 12),
            _BillRow('Item MRP', bill.mrpTotal, muted: true),
            if (bill.mrpSavings > 0)
              _BillRow(
                'Product Discount',
                -bill.mrpSavings,
                color: AppColors.emeraldPrimary,
              ),
            _BillRow(
              'Delivery Fee',
              bill.deliveryFee,
              muted: bill.deliveryFee == 0,
              overrideLabel:
                  bill.hasFreeDelivery ? 'Delivery Fee (FREE 🎉)' : null,
            ),
            _BillRow('Packaging', bill.packagingCharge, muted: true),
            _BillRow('Taxes (5%)', bill.taxes, muted: true),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),
            _BillRow('To Pay', bill.total, bold: true),
          ],
        ),
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow(
    this.label,
    this.amount, {
    this.bold = false,
    this.muted = false,
    this.color,
    this.overrideLabel,
  });
  final String label;
  final double amount;
  final bool bold;
  final bool muted;
  final Color? color;
  final String? overrideLabel;

  @override
  Widget build(BuildContext context) {
    final textColor = color ??
        (muted ? AppColors.textSecondary : AppColors.textPrimary);
    final sign = amount < 0 ? '-' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            overrideLabel ?? label,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            '$sign₹${amount.abs().toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
