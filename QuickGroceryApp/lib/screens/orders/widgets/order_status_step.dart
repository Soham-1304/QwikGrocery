import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Single visual step indicator along vertical timeline in order tracking.
class OrderStatusStep extends StatelessWidget {
  const OrderStatusStep({
    super.key,
    required this.label,
    required this.active,
    required this.last,
  });

  final String label;
  final bool active;
  final bool last;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.emeraldPrimary : Colors.white,
                  border: Border.all(
                    color: active
                        ? AppColors.emeraldPrimary
                        : const Color(0xFFBEC8BE),
                  ),
                ),
                child: active
                    ? const Icon(Icons.check, size: 11, color: Colors.white)
                    : null,
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    color: active
                        ? AppColors.emeraldPrimary
                        : const Color(0xFFDCE3DB),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1, bottom: 18),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                color: active ? Colors.black87 : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
