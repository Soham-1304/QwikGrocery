import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/product.dart';
import '../state/cart_scope.dart';

/// Compact in-card or detail-page quantity stepper.
/// Shows "+ ADD" when qty is 0; morphs to "- [n] +" when active.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.product,
    this.compact = true,
  });

  final Product product;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final qty = cart.quantityOf(product.id);

    if (!product.available) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Out of stock',
          style: TextStyle(
            fontSize: compact ? 11 : 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (qty == 0) {
      return _AddButton(
        compact: compact,
        onAdd: () => cart.add(product),
      );
    }

    return _ActiveStepper(
      qty: qty,
      compact: compact,
      onIncrement: () => cart.increment(product),
      onDecrement: () => cart.decrement(product.id),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.compact, required this.onAdd});
  final bool compact;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 6 : 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.emeraldPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: compact ? 14 : 18, color: Colors.white),
            SizedBox(width: compact ? 2 : 4),
            Text(
              'ADD',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: compact ? 12 : 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveStepper extends StatelessWidget {
  const _ActiveStepper({
    required this.qty,
    required this.compact,
    required this.onIncrement,
    required this.onDecrement,
  });
  final int qty;
  final bool compact;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 28.0 : 36.0;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.emeraldPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(size: size, icon: Icons.remove, onTap: onDecrement),
          SizedBox(
            width: compact ? 26 : 34,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: compact ? 13 : 15,
              ),
            ),
          ),
          _StepBtn(size: size, icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({
    required this.size,
    required this.icon,
    required this.onTap,
  });
  final double size;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: SizedBox(
      width: size,
      height: size,
      child: Icon(icon, size: size * 0.5, color: Colors.white),
    ),
  );
}
