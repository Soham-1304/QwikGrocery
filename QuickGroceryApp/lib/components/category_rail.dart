import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Horizontal scrollable category icon rail.
class CategoryRail extends StatelessWidget {
  const CategoryRail({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  static const _categoryIcons = <String, IconData>{
    'Vegetables': Icons.eco_outlined,
    'Fruits': Icons.apple,
    'Dairy': Icons.water_drop_outlined,
    'Grains': Icons.grain,
    'Bakery': Icons.bakery_dining_outlined,
    'Beverages': Icons.local_drink_outlined,
    'Snacks': Icons.cookie_outlined,
    'Noodles': Icons.ramen_dining_outlined,
    'Pulses': Icons.spa_outlined,
    'Eggs': Icons.egg_outlined,
  };

  static const _categoryColors = <String, Color>{
    'Vegetables': Color(0xFF2E7D32),
    'Fruits': Color(0xFFE53935),
    'Dairy': Color(0xFF1565C0),
    'Grains': Color(0xFF6D4C41),
    'Bakery': Color(0xFFEF6C00),
    'Beverages': Color(0xFF00838F),
    'Snacks': Color(0xFFC62828),
    'Noodles': Color(0xFFAD1457),
    'Pulses': Color(0xFF4E342E),
    'Eggs': Color(0xFFF9A825),
  };

  IconData _icon(String cat) =>
      _categoryIcons[cat] ?? Icons.category_outlined;

  Color _color(String cat) =>
      _categoryColors[cat] ?? AppColors.emeraldPrimary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSelected = cat == selected;
          final color = _color(cat);
          return GestureDetector(
            onTap: () => onSelect(isSelected ? '' : cat),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withAlpha(30)
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : AppColors.outline,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    _icon(cat),
                    color: isSelected ? color : AppColors.textSecondary,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 62,
                  child: Text(
                    cat,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
