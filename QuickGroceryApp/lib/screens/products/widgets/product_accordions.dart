import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProductAccordions extends StatefulWidget {
  const ProductAccordions({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  State<ProductAccordions> createState() => _ProductAccordionsState();
}

class _ProductAccordionsState extends State<ProductAccordions> {
  bool _open = false;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.outline),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(widget.icon, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(
                  _open ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (_open) ...[
          const Divider(height: 1),
          widget.child,
        ],
      ],
    ),
  );
}

class NutritionTable extends StatelessWidget {
  const NutritionTable({super.key, required this.info});
  final Map<String, String> info;

  @override
  Widget build(BuildContext context) => Column(
    children: info.entries.map((e) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Text(e.key, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(
            e.value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    )).toList(),
  );
}
