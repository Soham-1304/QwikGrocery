import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models.dart';
import '../../services/api_client.dart';
import '../../widgets/common_widgets.dart';
import 'tracking_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key, required this.api});
  final ApiClient api;
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<GroceryOrder>> _orders;
  Timer? _pollTimer;
  bool _polling = false;
  @override
  void initState() {
    super.initState();
    _orders = widget.api.orders();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => unawaited(_pollOrders()),
    );
  }

  void _retry() {
    setState(() {
      _orders = widget.api.orders();
    });
  }

  Future<void> _pollOrders() async {
    if (_polling) return;
    _polling = true;
    try {
      final orders = await widget.api.orders();
      if (mounted) setState(() => _orders = Future.value(orders));
    } catch (_) {
      // Keep the last successful order list visible during transient failures.
    } finally {
      _polling = false;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<GroceryOrder>>(
    future: _orders,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting &&
          !snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError && !snapshot.hasData) {
        return Problem(message: 'Orders couldn’t load.', onRetry: _retry);
      }
      final orders = snapshot.data ?? [];
      if (orders.isEmpty) {
        return const EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No orders yet',
          detail: 'Orders you place will appear here.',
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: order.isInProgress
                    ? const Color(0xFFFFD54F)
                    : (order.isComplete
                        ? const Color(0xFFA5D6A7)
                        : const Color(0xFFEF9A9A)),
                width: order.isInProgress ? 1.5 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TrackingPage(order: order, api: widget.api),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        _OrderStatusIndicator(order: order),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.itemsSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${order.totalItemQuantity} ${order.totalItemQuantity == 1 ? 'item' : 'items'} · ${order.createdAt.toLocal().toString().substring(0, 16)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              money(order.totalCents),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _OrderStatusIndicator extends StatelessWidget {
  const _OrderStatusIndicator({required this.order});
  final GroceryOrder order;

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
