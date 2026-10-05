import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models.dart';
import '../../services/api_client.dart';
import '../../services/api_exception.dart';
import '../../services/session.dart';
import '../../widgets/common_widgets.dart';

class StaffOrdersPage extends StatefulWidget {
  const StaffOrdersPage({super.key, required this.api, required this.session});
  final ApiClient api;
  final SessionController session;
  @override
  State<StaffOrdersPage> createState() => _StaffOrdersPageState();
}

class _StaffOrdersPageState extends State<StaffOrdersPage> {
  late Future<List<GroceryOrder>> _orders;
  String? _busyOrder;
  bool _polling = false;
  Timer? _pollTimer;
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
    _orders = widget.api.staffOrders();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => unawaited(_pollOrders()),
    );
  }

  void _reload() {
    final orders = widget.api.staffOrders();
    setState(() => _orders = orders);
  }

  Future<void> _pollOrders() async {
    if (_polling) return;
    _polling = true;
    try {
      final orders = await widget.api.staffOrders();
      if (mounted) setState(() => _orders = Future.value(orders));
    } catch (_) {
      // Keep the last successful list visible during transient API failures.
    } finally {
      _polling = false;
    }
  }

  Future<void> _advance(GroceryOrder order) async {
    final index = _statuses.indexOf(order.status);
    if (index < 0 || index >= _statuses.length - 1) return;
    setState(() => _busyOrder = order.id);
    try {
      final updated = await widget.api.setOrderStatus(
        order.id,
        _statuses[index + 1],
      );
      final orders = await _orders;
      if (mounted) {
        setState(
          () => _orders = Future.value(
            orders
                .map((item) => item.id == updated.id ? updated : item)
                .toList(),
          ),
        );
      }
    } on ApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _busyOrder = null);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('QwikGrocery · Staff orders'),
      actions: [
        IconButton(
          onPressed: _reload,
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          onPressed: widget.session.signOut,
          tooltip: 'Sign out',
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: FutureBuilder<List<GroceryOrder>>(
      future: _orders,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError && !snapshot.hasData)
          return Problem(
            message: 'Orders could not load. Staff access may be missing.',
            onRetry: _reload,
          );
        final orders = snapshot.data ?? [];
        if (orders.isEmpty)
          return const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No orders yet',
            detail: 'New customer orders will appear here.',
          );
        return ListView(
          padding: const EdgeInsets.all(16),
          children: orders.map((order) {
            final index = _statuses.indexOf(order.status);
            final next = index >= 0 && index < _statuses.length - 1
                ? _statuses[index + 1]
                : null;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Order ${order.id}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          money(order.totalCents),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${statusLabel(order.status)} · ${order.items.length} item types',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (order.status == 'out_for_delivery')
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Demo rider assigned · Kharghar Sector 12',
                          style: TextStyle(
                            color: AppColors.emeraldPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (next != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.tonal(
                          onPressed: _busyOrder == order.id
                              ? null
                              : () => _advance(order),
                          child: Text(
                            _busyOrder == order.id
                                ? 'Updating…'
                                : 'Move to ${statusLabel(next)}',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    ),
  );
}
