import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models.dart';
import '../../services/api_client.dart';
import '../../widgets/common_widgets.dart';
import 'widgets/demo_delivery_map.dart';
import 'widgets/order_bill_details_card.dart';
import 'widgets/order_items_card.dart';
import 'widgets/order_metadata_card.dart';
import 'widgets/order_status_step.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key, required this.order, required this.api});
  final GroceryOrder order;
  final ApiClient api;

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  late Stream<GroceryOrder> _orderStream;
  static const _statuses = [
    'placed',
    'confirmed',
    'preparing',
    'out_for_delivery',
    'delivered',
  ];

  @override
  void initState() {
    super.initState();
    _orderStream = widget.api.orderStream(widget.order.id);
  }

  void _refresh() {
    setState(() {
      _orderStream = widget.api.orderStream(widget.order.id);
    });
  }

  Widget _buildStatusPill(GroceryOrder order) {
    final Color dotColor;
    final Color bgColor;
    final Color textColor;
    final String label;

    if (order.isComplete) {
      dotColor = const Color(0xFF2E7D32);
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF1B5E20);
      label = 'Delivered';
    } else if (order.isCancelled) {
      dotColor = const Color(0xFFC62828);
      bgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFB71C1C);
      label = 'Cancelled';
    } else {
      dotColor = const Color(0xFFF57F17);
      bgColor = const Color(0xFFFFF8E1);
      textColor = const Color(0xFFE65100);
      label = statusLabel(order.status);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Delivery tracking'),
      actions: [
        IconButton(
          onPressed: _refresh,
          tooltip: 'Refresh status',
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: StreamBuilder<GroceryOrder>(
      stream: _orderStream,
      initialData: widget.order,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final order = snapshot.data!;
        final current = _statuses.indexOf(order.status);

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          children: [
            // Compact Order ID and Highlighted Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      money(order.totalCents),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                _buildStatusPill(order),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Placed on ${order.createdAt.toLocal().toString().substring(0, 16)} · Status updates live',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),

            // Delivery Status Stepper Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.outline),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: List.generate(
                    _statuses.length,
                    (i) => OrderStatusStep(
                      label: statusLabel(_statuses[i]),
                      active: i <= current,
                      last: i == _statuses.length - 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Live Interactive Map (when out for delivery)
            if (order.delivery?['simulated'] == true) ...[
              DemoDeliveryMap(order: order),
              const SizedBox(height: 14),
            ] else
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.outline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          order.status == 'delivered'
                              ? 'Delivery is complete.'
                              : 'Interactive route map appears when your order is out for delivery.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 14),

            // Items in this order
            OrderItemsCard(order: order),
            const SizedBox(height: 14),

            // Bill Breakdown & Tally
            OrderBillDetailsCard(order: order),
            const SizedBox(height: 14),

            // Order & Delivery Details Metadata
            OrderMetadataCard(order: order),
            const SizedBox(height: 24),
          ],
        );
      },
    ),
  );
}
