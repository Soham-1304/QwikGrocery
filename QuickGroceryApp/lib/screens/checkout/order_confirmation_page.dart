import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models.dart';
import '../../services/api_client.dart';
import '../../widgets/common_widgets.dart';
import '../orders/tracking_page.dart';

/// Screen displayed after successfully placing an order.
class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({
    super.key,
    required this.order,
    required this.api,
  });

  final GroceryOrder order;
  final ApiClient api;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Order placed')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.emeraldPrimary,
            ),
            const SizedBox(height: 18),
            Text(
              'Your order is in.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Order ${order.id}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery address',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(order.address),
                    const Divider(height: 28),
                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text('${item['quantity']} × ${item['name']}'),
                      ),
                    ),
                    const Divider(height: 28),
                    MoneyRow(
                      label: 'Total',
                      cents: order.totalCents,
                      bold: true,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Status: ${statusLabel(order.status)}',
                      style: const TextStyle(
                        color: AppColors.emeraldPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrackingPage(order: order, api: api),
                  ),
                ),
                child: const Text('Track this order'),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Back to groceries'),
            ),
          ],
        ),
      ),
    ),
  );
}
