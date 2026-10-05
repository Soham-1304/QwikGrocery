import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum SortOrder { none, priceLow, priceHigh, discount }

class CatalogSortSheet extends StatelessWidget {
  const CatalogSortSheet({super.key, required this.current});
  final SortOrder current;

  @override
  Widget build(BuildContext context) {
    final options = [
      ('Default order', SortOrder.none, Icons.list_rounded),
      ('Price: Low to High', SortOrder.priceLow, Icons.arrow_upward),
      ('Price: High to Low', SortOrder.priceHigh, Icons.arrow_downward),
      ('Best Discount', SortOrder.discount, Icons.local_offer_outlined),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort by',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ...options.map((opt) {
              final (label, order, icon) = opt;
              final isSelected = current == order;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  icon,
                  color: isSelected
                      ? AppColors.emeraldPrimary
                      : AppColors.textSecondary,
                ),
                title: Text(
                  label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.emeraldPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.emeraldPrimary,
                      )
                    : null,
                onTap: () => Navigator.pop(context, order),
              );
            }),
          ],
        ),
      ),
    );
  }
}
