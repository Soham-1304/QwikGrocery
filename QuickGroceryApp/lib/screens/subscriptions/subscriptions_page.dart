import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models.dart';
import '../../services/api_client.dart';
import '../../widgets/common_widgets.dart';
import 'subscription_form_page.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key, required this.api});
  final ApiClient api;
  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  late Future<List<GrocerySubscription>> _subscriptions;
  @override
  void initState() {
    super.initState();
    _subscriptions = widget.api.subscriptions();
  }

  void _reload() {
    final subscriptions = widget.api.subscriptions();
    setState(() {
      _subscriptions = subscriptions;
    });
  }

  Future<void> _edit([GrocerySubscription? subscription]) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SubscriptionFormPage(api: widget.api, existing: subscription),
      ),
    );
    if (mounted) _reload();
  }

  Future<void> _toggle(GrocerySubscription sub) async {
    try {
      await widget.api.setSubscriptionActive(sub.id, !sub.active);
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !sub.active
                  ? 'Scheduled order reactivated.'
                  : 'Scheduled order paused. It will not run until reactivated.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _delete(GrocerySubscription sub) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete scheduled order?'),
        content: const Text(
          'This scheduled order will be permanently deleted and will stop placing automatic deliveries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await widget.api.deleteSubscription(sub.id);
        _reload();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scheduled order deleted.')),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.toString())));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _edit(),
      icon: const Icon(Icons.add),
      label: const Text('Schedule order'),
    ),
    body: RefreshIndicator(
      onRefresh: () async {
        _reload();
        await _subscriptions;
      },
      child: FutureBuilder<List<GrocerySubscription>>(
        future: _subscriptions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Problem(
              message: 'Scheduled orders couldn’t load.',
              onRetry: _reload,
            );
          }
          final values = snapshot.data ?? [];
          if (values.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                const EmptyState(
                  icon: Icons.calendar_month_outlined,
                  title: 'No scheduled orders',
                  detail:
                      'Choose groceries, a delivery address and time to schedule recurring deliveries.',
                ),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            itemCount: values.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final sub = values[index];
              final isPaused = !sub.active;

              return Card(
                elevation: 0,
                color: isPaused ? const Color(0xFFF5F5F5) : AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isPaused
                        ? Colors.grey.shade300
                        : AppColors.outline,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isPaused
                              ? Colors.grey.shade200
                              : AppColors.emeraldLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isPaused
                              ? Icons.pause_circle_outline
                              : Icons.calendar_month,
                          color: isPaused
                              ? Colors.grey.shade600
                              : AppColors.emeraldPrimary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    sub.items
                                        .map((item) =>
                                            '${item.quantity} × ${item.productName}')
                                        .join(', '),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: isPaused
                                          ? Colors.grey.shade700
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isPaused
                                        ? Colors.grey.shade300
                                        : AppColors.emeraldLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isPaused ? 'PAUSED' : 'ACTIVE',
                                    style: TextStyle(
                                      color: isPaused
                                          ? Colors.grey.shade800
                                          : AppColors.emeraldPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isPaused
                                  ? 'Paused · Scheduled order is inactive and will not place deliveries'
                                  : '${sub.frequency} at ${sub.deliveryTime} · Next: ${sub.nextRunAt?.toLocal().toString().substring(0, 16) ?? 'Pending'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isPaused
                                    ? Colors.grey.shade600
                                    : AppColors.textSecondary,
                                fontWeight: isPaused ? FontWeight.w500 : FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'QwikWallet · ${money(sub.estimatedTotalCents)} estimated · ${sub.address}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isPaused
                                    ? Colors.grey.shade500
                                    : AppColors.textSecondary,
                              ),
                            ),
                            if (sub.lastRunStatus != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Last run: ${sub.lastRunStatus}${sub.lastRunError == null ? '' : ' · ${sub.lastRunError}'}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isPaused
                                      ? Colors.grey.shade500
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (value) {
                          if (value == 'edit') _edit(sub);
                          if (value == 'toggle') _toggle(sub);
                          if (value == 'delete') _delete(sub);
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  sub.active
                                      ? Icons.pause_circle_outline
                                      : Icons.play_circle_outline,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(sub.active ? 'Pause' : 'Reactivate'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  );
}
