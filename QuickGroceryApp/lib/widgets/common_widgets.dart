import 'package:flutter/material.dart';

export '../core/utils/currency_formatter.dart' show money, CurrencyFormatter;
import '../core/theme/app_colors.dart';
import '../core/utils/currency_formatter.dart';

const _green = AppColors.oldGreen;
const _yellow = AppColors.oldYellow;
const _black = AppColors.black;
const _muted = AppColors.muted;
const _paleYellow = AppColors.paleYellow;

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: _paleYellow,
    child: url.isEmpty
        ? const Center(
            child: Icon(
              Icons.local_grocery_store_outlined,
              color: _green,
              size: 36,
            ),
          )
        : Image.network(
            url,
            fit: BoxFit.cover,
            width: double.infinity,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, _, _) => const Center(
              child: Icon(Icons.broken_image_outlined, color: _green, size: 34),
            ),
          ),
  );
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(
        radius: 18,
        backgroundColor: _yellow,
        child: Icon(Icons.local_grocery_store, color: _green, size: 19),
      ),
      SizedBox(width: 8),
      Text(
        'QwikGrocery',
        style: TextStyle(
          fontSize: 19,
          color: _black,
          fontWeight: FontWeight.w800,
          letterSpacing: -.4,
        ),
      ),
    ],
  );
}

class MoneyRow extends StatelessWidget {
  const MoneyRow({
    super.key,
    required this.label,
    required this.cents,
    this.bold = false,
  });

  final String label;
  final int cents;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          money(cents),
          style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class Problem extends StatelessWidget {
  const Problem({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 36, color: _muted),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    this.action,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: _muted),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted),
          ),
          if (action != null) action!,
        ],
      ),
    ),
  );
}

String statusLabel(String status) => switch (status) {
  'placed' => 'Order placed',
  'confirmed' => 'Confirmed',
  'preparing' => 'Preparing',
  'out_for_delivery' => 'Out for delivery',
  'delivered' => 'Delivered',
  'cancelled' => 'Cancelled',
  _ => status,
};
